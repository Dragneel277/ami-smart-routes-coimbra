# Pseudocódigo — Inferência de Custos Contextuais nas Rotas

Este ficheiro explica de forma mais simples como foi pensada a lógica do projeto para calcular custos diferentes nas rotas. A ideia principal foi não usar só a distância da estrada, mas também algum contexto da cidade, como zonas com mais trânsito, eventos, pontos de observação e períodos do dia.

Também são indicados os ficheiros de exportação que foram gerados para permitir abrir ou recriar os dados do projeto.

---

## 1. Objetivo desta lógica

O objetivo foi criar uma forma de o sistema calcular rotas diferentes conforme o contexto.

Normalmente, uma rota é calculada apenas com base na menor distância. Neste projeto, a ideia foi adicionar custos extra a algumas estradas, dependendo de fatores como:

* trânsito em certas zonas;
* eventos académicos ou urbanos;
* zonas com maior concentração de pessoas;
* períodos como manhã, fim da tarde ou fim de semana;
* pontos de contexto recolhidos ou criados no projeto.

Assim, o sistema consegue calcular uma rota `normal`, `morning`, `evening` ou `weekend`.

---

## 2. Ficheiros exportados

Para deixar o projeto mais fácil de abrir e reproduzir, foram criados dois ficheiros principais de exportação:

```text
database/smart_routes_tables.sql
```

Este ficheiro serve para recriar as tabelas principais da base de dados PostGIS.

```text
exports/smart_routes_layers.gpkg
```

Este ficheiro é um GeoPackage e pode ser aberto diretamente no QGIS, sem precisar configurar a base de dados PostGIS.

O GeoPackage contém estas camadas:

```text
roads
context_reports
crowded_zones
urban_events
road_context_penalties
route_results
```

A ideia é que, se alguém quiser só visualizar os dados, pode usar o `.gpkg`. Se quiser recriar a base de dados e testar a parte técnica, pode usar o `.sql`.

---

## 3. Tabelas principais usadas

### `roads`

Esta é a tabela principal da rede viária. Cada linha representa uma estrada ou segmento de estrada.

Campos importantes:

```text
id
geom
source
target
highway
length_meters
cost_normal
cost_morning
cost_evening
cost_weekend
```

Esta tabela é usada pelo pgRouting para calcular os caminhos.

---

### `context_reports`

Esta tabela guarda pontos de contexto. São pontos no mapa que representam alguma observação relevante.

Exemplos:

```text
traffic
danger
transport
education
nightlife
```

No projeto, estes pontos ajudam a indicar zonas onde pode existir mais movimento ou algum problema.

---

### `crowded_zones`

Esta tabela guarda zonas desenhadas como polígonos. São áreas onde existe mais concentração ou fluxo.

Exemplos:

```text
Rua do Brasil
Rotunda da Portagem
Alma Shopping / Estádio
Recinto Queima / Latada
```

Cada zona pode ter um nível de concentração:

```text
low
medium
high
```

---

### `urban_events`

Esta tabela guarda eventos urbanos ou académicos.

Exemplos:

```text
Queima das Fitas
Festa das Latas
Semana Aberta da Universidade de Coimbra
eventos culturais
```

Esta tabela ajuda principalmente a justificar o contexto `weekend` ou `event/night`.

---

### `road_context_penalties`

Esta é uma tabela intermédia. Foi criada para ligar as estradas aos contextos que afetam essas estradas.

Ou seja, esta tabela responde a perguntas como:

```text
Que estrada foi afetada?
Por que ponto ou zona foi afetada?
Qual foi o fator de penalização?
Em que período do dia essa penalização faz sentido?
```

Campos importantes:

```text
road_id
context_source
context_name
context_type
crowding
time_context
penalty_factor
reason
geom
```

---

### `route_results`

Esta é a tabela final onde ficam guardadas as rotas calculadas.

Cada rota tem:

```text
route_name
route_type
demo_name
origin_place
destination_place
total_cost
geom
```

Depois esta tabela é aberta no QGIS para visualizar as linhas das rotas.

---

## 4. Infográfico simples da ligação entre as tabelas

```mermaid
flowchart TD

    A[context_reports<br/>pontos de contexto] --> D[road_context_penalties]
    B[crowded_zones<br/>zonas congestionadas] --> D
    C[urban_events<br/>eventos urbanos] --> B

    D --> E[roads<br/>custos atualizados]

    E --> F[create_dynamic_route()]
    G[roads_vertices_pgr<br/>nós da rede] --> F

    F --> H[pgr_dijkstra<br/>cálculo da rota]
    H --> I[route_results<br/>rotas finais]
    I --> J[QGIS<br/>visualização no mapa]

    K[exports/smart_routes_layers.gpkg] --> J
    L[database/smart_routes_tables.sql] --> E
```

---

## 5. Lógica geral do sistema

A lógica foi feita em várias etapas.

Primeiro, a rede viária é carregada na tabela `roads`. Depois são adicionadas as camadas de contexto, como pontos de observação, zonas congestionadas e eventos.

Depois, o sistema cruza espacialmente estas camadas com a rede viária.

A ideia é:

```text
se uma estrada passa dentro de uma zona congestionada,
então essa estrada deve ter custo maior.

se uma estrada está perto de um ponto de contexto,
então essa estrada também pode ter custo maior.

se uma estrada está associada a uma zona de evento,
então o custo weekend/event pode aumentar.
```

---

## 6. Pseudocódigo da criação dos custos base

Antes de aplicar contexto, todas as estradas começam com o custo igual ao seu comprimento.

```pseudocode
PARA cada estrada EM roads FAZER

    length_meters = calcular comprimento da geometria

    cost_normal = length_meters
    cost_morning = length_meters
    cost_evening = length_meters
    cost_weekend = length_meters

FIM
```

Nesta fase ainda não existe inteligência contextual. O sistema só sabe a distância da estrada.

---

## 7. Pseudocódigo para zonas congestionadas

Depois o sistema verifica se as estradas cruzam zonas congestionadas.

```pseudocode
PARA cada estrada r EM roads FAZER

    PARA cada zona z EM crowded_zones FAZER

        SE r.geom intersecta z.geom ENTÃO

            SE z.crowding = 'high' ENTÃO
                penalty_factor = 1.75

            SENÃO SE z.crowding = 'medium' ENTÃO
                penalty_factor = 1.35

            SENÃO SE z.crowding = 'low' ENTÃO
                penalty_factor = 1.05

            SENÃO
                penalty_factor = 1.10

            guardar esta penalização em road_context_penalties

        FIM SE

    FIM

FIM
```

A operação espacial principal aqui é:

```sql
ST_Intersects(roads.geom, crowded_zones.geom)
```

Ou seja, o PostGIS verifica se a linha da estrada passa dentro ou cruza o polígono da zona.

---

## 8. Pseudocódigo para pontos de contexto

Além das zonas, também foram usados pontos de contexto.

Neste caso, a estrada não precisa intersectar o ponto, porque um ponto é muito pequeno. Então é usada uma distância, por exemplo 50 metros.

```pseudocode
PARA cada estrada r EM roads FAZER

    PARA cada ponto p EM context_reports FAZER

        SE distância entre r.geom e p.geom <= 50 metros ENTÃO

            SE p.crowding = 'high' ENTÃO
                penalty_factor = 1.75

            SENÃO SE p.crowding = 'medium' ENTÃO
                penalty_factor = 1.35

            SENÃO SE p.crowding = 'low' ENTÃO
                penalty_factor = 1.05

            SENÃO
                penalty_factor = 1.10

            guardar esta penalização em road_context_penalties

        FIM SE

    FIM

FIM
```

A operação espacial principal aqui é:

```sql
ST_DWithin(roads.geom::geography, context_reports.geom::geography, 50)
```

Isto significa que o sistema procura estradas próximas dos pontos de contexto.

---

## 9. Como os custos são atualizados

Depois de preencher a tabela `road_context_penalties`, os custos da tabela `roads` são atualizados.

A ideia é usar a maior penalização encontrada para cada estrada.

### Custo normal

```pseudocode
cost_normal = length_meters
```

O custo normal não tem penalização.

---

### Custo morning

```pseudocode
PARA cada estrada EM roads FAZER

    procurar maior penalty_factor
    em road_context_penalties
    onde road_id = roads.id
    e time_context está relacionado com morning

    SE existir penalização ENTÃO
        cost_morning = cost_normal * penalty_factor
    SENÃO
        cost_morning = cost_normal

FIM
```

---

### Custo evening

```pseudocode
PARA cada estrada EM roads FAZER

    procurar maior penalty_factor
    em road_context_penalties
    onde road_id = roads.id
    e time_context está relacionado com evening

    SE existir penalização ENTÃO
        cost_evening = cost_normal * penalty_factor
    SENÃO
        cost_evening = cost_normal

FIM
```

---

### Custo weekend

```pseudocode
PARA cada estrada EM roads FAZER

    procurar maior penalty_factor
    em road_context_penalties
    onde road_id = roads.id
    e time_context está relacionado com weekend, event ou night

    SE existir penalização ENTÃO
        cost_weekend = cost_normal * penalty_factor
    SENÃO
        cost_weekend = cost_normal

FIM
```

---

## 10. Como entra na função principal

A função principal é `create_dynamic_route()`.

Ela recebe:

```text
longitude da origem
latitude da origem
longitude do destino
latitude do destino
tipo de rota
nome da rota
nome da demo
nome do local de origem
nome do local de destino
```

Depois faz três coisas principais:

1. encontra o nó mais próximo da origem;
2. encontra o nó mais próximo do destino;
3. escolhe que coluna de custo vai usar.

---

## 11. Pseudocódigo da função principal

```pseudocode
FUNÇÃO create_dynamic_route(origem, destino, route_type)

    start_node = nó mais próximo da origem
    end_node = nó mais próximo do destino

    SE route_type = 'normal' ENTÃO
        cost_column = cost_normal

    SENÃO SE route_type = 'morning' ENTÃO
        cost_column = cost_morning

    SENÃO SE route_type = 'evening' ENTÃO
        cost_column = cost_evening

    SENÃO SE route_type = 'weekend' ENTÃO
        cost_column = cost_weekend

    FIM SE

    rota = pgr_dijkstra(
        roads,
        start_node,
        end_node,
        cost_column
    )

    geometria_final = juntar segmentos da rota

    custo_total = somar custos dos segmentos

    inserir resultado em route_results

FIM FUNÇÃO
```

---

## 12. Como o pgRouting usa os custos

O pgRouting precisa de uma tabela que funcione como grafo.

A estrutura usada é:

```text
id
source
target
cost
reverse_cost
```

No projeto, estes valores vêm da tabela `roads`.

Exemplo para rota normal:

```text
id = roads.id
source = roads.source
target = roads.target
cost = roads.cost_normal
reverse_cost = roads.cost_normal
```

Exemplo para rota evening:

```text
id = roads.id
source = roads.source
target = roads.target
cost = roads.cost_evening
reverse_cost = roads.cost_evening
```

Portanto, o pgRouting não escolhe a estrada com menor distância diretamente. Ele escolhe o caminho com menor soma de custos.

---

## 13. Diferença entre distância e custo

Uma estrada pode ter:

```text
length_meters = 100
cost_normal = 100
cost_evening = 175
```

Isto significa que fisicamente a estrada tem 100 metros, mas no período evening ela tem custo 175 por causa do contexto.

Assim, o sistema pode evitar essa estrada se existir uma alternativa melhor.

---

## 14. Como os resultados aparecem no QGIS

Depois da função calcular a rota, o resultado é guardado em `route_results`.

A camada `route_results` é carregada no QGIS.

No QGIS, as rotas são separadas por:

```text
route_type
```

Exemplo:

```text
normal
morning
evening
weekend
```

Desta forma, é possível comparar visualmente as rotas no mapa.

---

## 15. Ligação com os ficheiros exportados

O ficheiro:

```text
database/smart_routes_tables.sql
```

permite recriar a base de dados com as tabelas principais.

O ficheiro:

```text
exports/smart_routes_layers.gpkg
```

permite abrir as camadas diretamente no QGIS.

A ligação entre os dois é simples:

```text
O SQL representa a estrutura e os dados em PostGIS.
O GeoPackage representa as mesmas camadas num formato mais fácil de abrir no QGIS.
```

---

## 16. Explicação simples para a apresentação

Durante a apresentação, esta parte pode ser explicada assim:

```text
A lógica do projeto foi criar custos diferentes para as estradas. Primeiro cada estrada tem como custo o seu comprimento. Depois, o sistema cruza as estradas com zonas congestionadas e pontos de contexto. Quando existe relação espacial, por exemplo uma estrada dentro de uma zona congestionada ou perto de um ponto de trânsito, essa estrada recebe uma penalização. Essa penalização é guardada numa tabela intermédia e depois usada para atualizar os custos morning, evening e weekend. Finalmente, a função principal escolhe o custo certo conforme o tipo de rota e o pgRouting calcula o caminho com menor custo acumulado.
```

---

## 17. Resumo final

```text
context_reports + crowded_zones + urban_events
        ↓
road_context_penalties
        ↓
roads com custos diferentes
        ↓
create_dynamic_route()
        ↓
pgr_dijkstra()
        ↓
route_results
        ↓
QGIS
```

A parte mais importante é que o sistema não desenha rotas manualmente. As rotas são calculadas automaticamente pelo pgRouting, usando os custos que foram ajustados com base no contexto urbano.
