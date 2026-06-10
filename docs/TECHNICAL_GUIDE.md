# Technical Guide

Este documento descreve a componente técnica do projeto **Sistema Inteligente de Recomendação de Rotas Sensível ao Tempo para Coimbra**.

O objetivo é explicar a estrutura da base de dados, as tabelas principais, a lógica de penalização contextual e a utilização do `pgRouting`.

## 1. Visão Geral Técnica

O projeto utiliza uma base de dados espacial PostgreSQL/PostGIS para armazenar a rede viária, eventos, zonas de contexto e resultados das rotas.

O fluxo técnico é:

```text
QGIS / MerginMaps
        ↓
PostgreSQL + PostGIS
        ↓
Lógica contextual de penalizações
        ↓
pgRouting
        ↓
route_results
        ↓
Visualização no QGIS
```

A rede viária é representada como um grafo, onde cada estrada possui:

* identificador (`id`);
* geometria (`geom`);
* nó de origem (`source`);
* nó de destino (`target`);
* tipo de estrada (`highway`);
* comprimento em metros (`length_meters`);
* custos temporais (`cost_normal`, `cost_morning`, `cost_evening`, `cost_weekend`).

## 2. Principais Tabelas

### 2.1 `roads`

Tabela principal da rede viária.

Campos principais:

```text
id
geom
source
target
highway
length
length_meters
cost_normal
cost_morning
cost_evening
cost_weekend
oneway
```

Função da tabela:

```text
Representa os segmentos da rede viária de Coimbra.
É a tabela usada diretamente pelo pgRouting.
```

Os campos `source` e `target` representam os nós do grafo.

Os campos de custo são usados para gerar diferentes tipos de rota:

```text
cost_normal   → rota normal
cost_morning  → rota com penalizações de manhã
cost_evening  → rota com penalizações de fim da tarde
cost_weekend  → rota com penalizações de eventos/noite/fim de semana
```

### 2.2 `context_reports`

Tabela de pontos de contexto urbano.

Tipos de contexto usados:

```text
danger
education
nightlife
traffic
transport
```

Campos principais:

```text
id
report_type
name
description
crowding
time_context
source
confidence
geom
```

Exemplos de pontos adicionados:

```text
Início Rua do Brasil
Fim Rua do Brasil
Rotunda da Portagem
Saída para Ponte de Santa Clara
Fluxo matinal escola/trabalho
Recinto Queima e Latada
```

Estes pontos foram baseados em observações locais e representam áreas onde existe maior fluxo de trânsito, circulação de pessoas ou impacto urbano.

### 2.3 `crowded_zones`

Tabela de zonas com diferentes níveis de concentração.

Campos principais:

```text
id
zone_name
zone_type
crowding
time_context
main_reason
source
confidence
geom
```

Valores usados no campo `crowding`:

```text
low
medium
high
```

Exemplos:

```text
Zona Rua do Brasil
Zona Estádio / Alma Shopping
Zona Rotunda da Portagem
Zona Ponte de Santa Clara
Zona Recinto Queima / Latada
Zona Fluxo Matinal Escola / Trabalho
```

Estas zonas são usadas para penalizar segmentos da rede viária que as intersectam.

### 2.4 `urban_events`

Tabela com eventos urbanos e académicos.

Campos principais:

```text
id
event_name
event_type
location_name
description
period
expected_crowding
time_context
source
confidence
geom
```

Exemplos de eventos:

```text
Queima das Fitas
Festa das Latas e do Caloiro
Festival das Artes / QuebraJazz
Erasmus+ Global Week
Semana Aberta da Universidade de Coimbra
```

A camada ajuda a representar momentos em que certas zonas podem ter maior concentração de pessoas e circulação.

### 2.5 `road_context_penalties`

Tabela intermediária que relaciona contexto urbano com a rede viária.

Campos principais:

```text
id
road_id
context_source
context_id
context_name
context_type
crowding
time_context
penalty_factor
reason
geom
```

Função:

```text
Guardar quais estradas foram afetadas por crowded_zones ou context_reports.
```

Exemplo:

```text
Se uma estrada intersecta uma crowded_zone com crowding = high,
essa estrada recebe penalty_factor = 1.75.
```

Esta tabela permite justificar tecnicamente porque determinadas estradas ficaram com custo maior.

### 2.6 `roads_vertices_pgr`

Tabela de nós da rede viária.

Campos principais:

```text
id
the_geom
```

Função:

```text
Permitir encontrar o nó mais próximo de uma coordenada manual de origem ou destino.
```

Esta tabela foi criada a partir dos campos `source` e `target` da tabela `roads`.

### 2.7 `route_results`

Tabela final com as rotas calculadas.

Campos principais:

```text
id
route_name
route_type
demo_name
origin_place
destination_place
recommended_time
origin_description
destination_description
total_cost
created_at
geom
```

Valores possíveis de `route_type`:

```text
normal
morning
evening
weekend
```

Esta tabela é carregada no QGIS e categorizada por `route_type`.

## 3. Preparação da Tabela `roads`

Os custos base foram criados/atualizados assim:

```sql
ALTER TABLE roads ADD COLUMN IF NOT EXISTS length_meters double precision;
ALTER TABLE roads ADD COLUMN IF NOT EXISTS cost_normal double precision;
ALTER TABLE roads ADD COLUMN IF NOT EXISTS cost_morning double precision;
ALTER TABLE roads ADD COLUMN IF NOT EXISTS cost_evening double precision;
ALTER TABLE roads ADD COLUMN IF NOT EXISTS cost_weekend double precision;

UPDATE roads
SET length_meters = ST_Length(geom::geography)
WHERE length_meters IS NULL OR length_meters = 0;

UPDATE roads
SET
    cost_normal = length_meters,
    cost_morning = length_meters,
    cost_evening = length_meters,
    cost_weekend = length_meters;
```

Nesta fase, todas as rotas usam apenas distância.

## 4. Criação da Tabela de Penalizações

A tabela `road_context_penalties` foi criada para guardar as penalizações contextuais:

```sql
DROP TABLE IF EXISTS road_context_penalties;

CREATE TABLE road_context_penalties (
    id SERIAL PRIMARY KEY,
    road_id bigint,
    context_source text,
    context_id integer,
    context_name text,
    context_type text,
    crowding text,
    time_context text,
    penalty_factor double precision,
    reason text,
    geom geometry(LineString, 4326)
);

CREATE INDEX idx_road_context_penalties_geom
ON road_context_penalties
USING GIST (geom);

CREATE INDEX idx_road_context_penalties_road_id
ON road_context_penalties (road_id);
```

## 5. Penalizações a Partir de `crowded_zones`

As estradas que intersectam zonas congestionadas recebem penalizações:

```sql
INSERT INTO road_context_penalties (
    road_id,
    context_source,
    context_id,
    context_name,
    context_type,
    crowding,
    time_context,
    penalty_factor,
    reason,
    geom
)
SELECT
    r.id AS road_id,
    'crowded_zones' AS context_source,
    cz.id AS context_id,
    cz.zone_name AS context_name,
    cz.zone_type AS context_type,
    cz.crowding,
    cz.time_context,
    CASE
        WHEN cz.crowding = 'high' THEN 1.75
        WHEN cz.crowding = 'medium' THEN 1.35
        WHEN cz.crowding = 'low' THEN 1.05
        ELSE 1.10
    END AS penalty_factor,
    cz.main_reason AS reason,
    r.geom
FROM roads r
JOIN crowded_zones cz
ON ST_Intersects(r.geom, cz.geom);
```

## 6. Penalizações a Partir de `context_reports`

As estradas próximas de pontos de contexto são penalizadas com base num raio de 50 metros:

```sql
INSERT INTO road_context_penalties (
    road_id,
    context_source,
    context_id,
    context_name,
    context_type,
    crowding,
    time_context,
    penalty_factor,
    reason,
    geom
)
SELECT
    r.id AS road_id,
    'context_reports' AS context_source,
    cr.id AS context_id,
    cr.name AS context_name,
    cr.report_type AS context_type,
    cr.crowding,
    cr.time_context,
    CASE
        WHEN cr.crowding = 'high' THEN 1.75
        WHEN cr.crowding = 'medium' THEN 1.35
        WHEN cr.crowding = 'low' THEN 1.05
        ELSE 1.10
    END AS penalty_factor,
    cr.description AS reason,
    r.geom
FROM roads r
JOIN context_reports cr
ON ST_DWithin(r.geom::geography, cr.geom::geography, 50);
```

## 7. Atualização dos Custos Dinâmicos

Antes de recalcular os custos, faz-se reset:

```sql
UPDATE roads
SET
    cost_morning = cost_normal,
    cost_evening = cost_normal,
    cost_weekend = cost_normal;
```

### 7.1 Custo da Manhã

```sql
UPDATE roads r
SET cost_morning = r.cost_normal * COALESCE((
    SELECT MAX(p.penalty_factor)
    FROM road_context_penalties p
    WHERE p.road_id = r.id
      AND (
          p.time_context ILIKE '%morning%'
          OR p.time_context ILIKE '%07%'
          OR p.time_context ILIKE '%08%'
      )
), 1.0);
```

### 7.2 Custo do Fim da Tarde

```sql
UPDATE roads r
SET cost_evening = r.cost_normal * COALESCE((
    SELECT MAX(p.penalty_factor)
    FROM road_context_penalties p
    WHERE p.road_id = r.id
      AND (
          p.time_context ILIKE '%evening%'
          OR p.time_context ILIKE '%16%'
          OR p.time_context ILIKE '%17%'
          OR p.time_context ILIKE '%18%'
      )
), 1.0);
```

### 7.3 Custo de Evento / Noite / Fim de Semana

```sql
UPDATE roads r
SET cost_weekend = r.cost_normal * COALESCE((
    SELECT MAX(p.penalty_factor)
    FROM road_context_penalties p
    WHERE p.road_id = r.id
      AND (
          p.time_context ILIKE '%weekend%'
          OR p.time_context ILIKE '%event%'
          OR p.time_context ILIKE '%night%'
      )
), 1.0);
```

## 8. Criação dos Vértices do pgRouting

A tabela `roads_vertices_pgr` permite encontrar o nó mais próximo de uma coordenada manual.

```sql
DROP TABLE IF EXISTS roads_vertices_pgr;

CREATE TABLE roads_vertices_pgr AS
SELECT DISTINCT ON (node_id)
    node_id AS id,
    geom_point AS the_geom
FROM (
    SELECT
        source AS node_id,
        ST_StartPoint(geom) AS geom_point
    FROM roads
    WHERE source IS NOT NULL

    UNION ALL

    SELECT
        target AS node_id,
        ST_EndPoint(geom) AS geom_point
    FROM roads
    WHERE target IS NOT NULL
) AS vertices
WHERE node_id IS NOT NULL
ORDER BY node_id;

CREATE INDEX idx_roads_vertices_pgr_geom
ON roads_vertices_pgr
USING GIST (the_geom);

CREATE INDEX idx_roads_vertices_pgr_id
ON roads_vertices_pgr (id);
```

## 9. Tabela `route_results`

```sql
DROP TABLE IF EXISTS route_results;

CREATE TABLE route_results (
    id SERIAL PRIMARY KEY,
    route_name text,
    route_type text,
    demo_name text,
    origin_place text,
    destination_place text,
    recommended_time text,
    origin_description text,
    destination_description text,
    total_cost double precision,
    created_at timestamp DEFAULT now(),
    geom geometry(MultiLineString, 4326)
);

CREATE INDEX idx_route_results_geom
ON route_results
USING GIST (geom);
```

## 10. Função `create_dynamic_route`

A função recebe coordenadas de origem/destino, escolhe a coluna de custo e guarda a rota em `route_results`.

```sql
CREATE OR REPLACE FUNCTION create_dynamic_route(
    p_origin_lon double precision,
    p_origin_lat double precision,
    p_dest_lon double precision,
    p_dest_lat double precision,
    p_route_type text,
    p_route_name text,
    p_demo_name text,
    p_origin_place text,
    p_destination_place text
)
RETURNS void AS
$$
DECLARE
    v_start_node bigint;
    v_end_node bigint;
    v_cost_column text;
    v_recommended_time text;
BEGIN
    SELECT id
    INTO v_start_node
    FROM roads_vertices_pgr
    ORDER BY the_geom <-> ST_SetSRID(ST_Point(p_origin_lon, p_origin_lat), 4326)
    LIMIT 1;

    SELECT id
    INTO v_end_node
    FROM roads_vertices_pgr
    ORDER BY the_geom <-> ST_SetSRID(ST_Point(p_dest_lon, p_dest_lat), 4326)
    LIMIT 1;

    IF p_route_type = 'morning' THEN
        v_cost_column := 'cost_morning';
        v_recommended_time := 'Rota calculada considerando maior fluxo antes das 08:00, associado a deslocações para escola e trabalho.';
    ELSIF p_route_type = 'evening' THEN
        v_cost_column := 'cost_evening';
        v_recommended_time := 'Rota calculada considerando maior fluxo entre 16:30 e 18:30, evitando zonas congestionadas quando existir alternativa.';
    ELSIF p_route_type = 'weekend' THEN
        v_cost_column := 'cost_weekend';
        v_recommended_time := 'Rota calculada considerando eventos, zonas de nightlife e maior ocupação urbana em períodos especiais.';
    ELSE
        v_cost_column := 'cost_normal';
        v_recommended_time := 'Rota normal baseada no comprimento da rede viária, sem penalizações contextuais.';
    END IF;

    EXECUTE format(
        $sql$
        INSERT INTO route_results (
            route_name,
            route_type,
            demo_name,
            origin_place,
            destination_place,
            recommended_time,
            origin_description,
            destination_description,
            total_cost,
            geom
        )
        SELECT
            %L AS route_name,
            %L AS route_type,
            %L AS demo_name,
            %L AS origin_place,
            %L AS destination_place,
            %L AS recommended_time,
            %L AS origin_description,
            %L AS destination_description,
            SUM(d.cost) AS total_cost,
            ST_Multi(ST_LineMerge(ST_Union(r.geom))) AS geom
        FROM pgr_dijkstra(
            'SELECT id, source, target, %I AS cost, %I AS reverse_cost FROM roads',
            %s,
            %s,
            false
        ) d
        JOIN roads r
        ON d.edge = r.id
        WHERE d.edge <> -1
        $sql$,
        p_route_name,
        p_route_type,
        p_demo_name,
        p_origin_place,
        p_destination_place,
        v_recommended_time,
        p_origin_place,
        p_destination_place,
        v_cost_column,
        v_cost_column,
        v_start_node,
        v_end_node
    );

END;
$$ LANGUAGE plpgsql;
```

## 11. Demos Criadas

Foram criadas quatro demos:

```text
Demo 1 — ISEC para Portagem
Demo 2 — ISEC para Rua do Brasil
Demo 3 — ISEC para Alma Shopping
Demo 4 — Portagem para Recinto Queima/Latada
```

Cada demo tem quatro rotas:

```text
normal
morning
evening
weekend
```

Total:

```text
4 demos × 4 tipos = 16 rotas
```

## 12. Query de Comparação Final

```sql
SELECT
    demo_name,
    route_type,
    origin_place,
    destination_place,
    ROUND(ST_Length(geom::geography)::numeric, 2) AS distance_meters,
    ROUND(total_cost::numeric, 2) AS contextual_cost,
    ROUND((total_cost - ST_Length(geom::geography))::numeric, 2) AS extra_context_cost
FROM route_results
ORDER BY demo_name, route_type;
```

Esta query mostra:

```text
distance_meters     → distância física da rota
contextual_cost     → custo usado pelo pgRouting
extra_context_cost  → penalização causada pelo contexto
```

## 13. Resultados Obtidos

Resumo dos resultados principais:

```text
Demo 1 — ISEC → Portagem
normal: 2731.60 m | cost 2731.60
morning: 2731.60 m | cost 2888.81
evening: 2753.25 m | cost 3183.80
weekend: 2731.60 m | cost 2731.60
```

```text
Demo 2 — ISEC → Rua do Brasil
normal: 1253.56 m | cost 1253.56
morning: 1253.56 m | cost 1428.42
evening: 1253.56 m | cost 1542.38
weekend: 1253.56 m | cost 1253.56
```

```text
Demo 3 — ISEC → Alma Shopping
normal: 2201.99 m | cost 2201.99
morning: 2201.99 m | cost 2333.58
evening: 2201.99 m | cost 2333.58
weekend: 2201.99 m | cost 2201.99
```

```text
Demo 4 — Portagem → Recinto Queima/Latada
normal: 272.12 m | cost 272.12
morning: 272.12 m | cost 272.12
evening: 272.12 m | cost 460.40
weekend: 272.12 m | cost 456.85
```

## 14. Interpretação

A distância física nem sempre muda, mas o custo contextual muda conforme o período temporal.

Isto demonstra que:

```text
O sistema não calcula apenas a rota mais curta.
O sistema calcula uma rota ponderada pelo contexto urbano e temporal.
```

Quando existe alternativa, a rota pode mudar de geometria. Quando o destino está dentro da zona congestionada, a rota pode manter a geometria mas apresentar custo superior.

## 15. Limitações Técnicas

Limitações atuais:

* dados de trânsito baseados em observações manuais;
* ausência de dados de trânsito em tempo real;
* penalizações definidas por regras simples;
* sentido das vias simplificado em algumas rotas;
* cálculo baseado em `pgr_dijkstra`;
* sem modelo preditivo de machine learning.

## 16. Possíveis Melhorias

Melhorias futuras:

* integração com dados reais de trânsito;
* penalizações atualizadas automaticamente;
* uso de APIs externas;
* suporte mais rigoroso a ruas de sentido único;
* utilização de A* ou algoritmos mais avançados;
* criação de plugin QGIS completo;
* utilização de modelos de machine learning para prever congestionamento;
* recolha contínua de dados via MerginMaps ou aplicação móvel.
