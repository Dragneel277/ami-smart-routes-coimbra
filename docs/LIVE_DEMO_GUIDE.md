# Live Demo Guide

Este documento serve como guia para a demonstração live do projeto no QGIS.

A apresentação está dividida em duas partes:

```text
1. Slides explicativos
2. Demonstração live no QGIS / PostgreSQL / MerginMaps
```

O objetivo da demonstração é mostrar que o sistema está funcional e que as rotas são calculadas com base em custos contextuais.

## 1. Objetivo da Demonstração

Demonstrar que o projeto:

* usa QGIS para visualização espacial;
* usa PostGIS para armazenar dados georreferenciados;
* usa pgRouting para calcular rotas;
* usa contexto urbano para alterar os custos da rede viária;
* gera rotas diferentes por período temporal;
* permite recolha/consulta de pontos com MerginMaps.

## 2. Preparação Antes da Apresentação

Antes de iniciar a apresentação, confirmar:

```text
PostgreSQL está ativo
Base de dados smart_routes está acessível
QGIS abre sem erros
Camada route_results está carregada
Camadas context_reports, crowded_zones e urban_events estão visíveis
Simbologia por route_type está aplicada
Filtros por demo_name funcionam
Projeto MerginMaps está sincronizado
```

## 3. Ordem Recomendada da Apresentação Live

### Parte 1 — Mostrar o Projeto QGIS

Abrir o QGIS e mostrar a estrutura das camadas:

```text
01_Base_Map
02_Study_Area
03_Input_Data
04_Request_Points
05_Context_and_Events
06_Routing_Results
```

Explicação:

```text
O projeto está organizado por grupos de camadas.
As camadas de contexto e eventos são usadas para representar zonas urbanas com maior fluxo.
As rotas calculadas aparecem no grupo Routing Results.
```

Mostrar principalmente:

```text
crowded_zones
urban_events
context_reports
route_results
```

## 4. Explicação das Camadas

### 4.1 `crowded_zones`

Explicar:

```text
Esta camada contém zonas com níveis de concentração: low, medium e high.
As zonas high e medium aumentam o custo das estradas que as atravessam.
```

Exemplos:

```text
Zona Rua do Brasil
Zona Rotunda da Portagem
Zona Estádio / Alma Shopping
Zona Recinto Queima / Latada
```

### 4.2 `context_reports`

Explicar:

```text
Esta camada contém pontos de observação local.
Os pontos representam trânsito, transporte, perigo, educação e nightlife.
```

Exemplos:

```text
Rotunda da Portagem
Rua do Brasil
Saída para Ponte de Santa Clara
Fluxo matinal escola/trabalho
```

### 4.3 `urban_events`

Explicar:

```text
Esta camada representa eventos urbanos ou académicos que podem influenciar a mobilidade.
```

Exemplos:

```text
Queima das Fitas
Festa das Latas e do Caloiro
Semana Aberta da Universidade de Coimbra
Erasmus+ Global Week
Festival das Artes / QuebraJazz
```

### 4.4 `route_results`

Explicar:

```text
Esta camada contém as rotas calculadas pelo pgRouting.
Cada rota tem um tipo: normal, morning, evening ou weekend.
```

## 5. Simbologia da Camada `route_results`

A camada `route_results` deve estar categorizada por:

```text
route_type
```

Cores recomendadas:

```text
normal  → azul
morning → laranja
evening → vermelho
weekend → roxo
```

Labels recomendados:

```qgis
"route_type" || ' | cost: ' || round("total_cost", 2)
```

Ou:

```qgis
"origin_place" || ' → ' || "destination_place" || '\n' ||
"route_type" || ' | cost: ' || round("total_cost", 2)
```

## 6. Demo 1 — ISEC para Portagem

Filtro QGIS:

```sql
"demo_name" = 'Demo 1 - ISEC para Portagem'
```

Mostrar as quatro rotas:

```text
normal
morning
evening
weekend
```

Explicação:

```text
Esta é a demonstração principal.
A rota evening tem uma geometria diferente da normal.
Isto mostra que o sistema consegue adaptar a rota quando existem penalizações no período do fim da tarde.
```

Resultados:

```text
normal  → 2731.60 m | cost 2731.60 | extra 0.00
morning → 2731.60 m | cost 2888.81 | extra 157.22
evening → 2753.25 m | cost 3183.80 | extra 430.55
weekend → 2731.60 m | cost 2731.60 | extra 0.00
```

Frase para dizer:

```text
Neste caso, a rota evening fica ligeiramente mais longa, mas isso acontece porque o sistema está a considerar zonas de maior fluxo no final da tarde. A rota não é apenas a mais curta, é a rota com menor custo contextual.
```

## 7. Demo 2 — ISEC para Rua do Brasil

Filtro QGIS:

```sql
"demo_name" = 'Demo 2 - ISEC para Rua do Brasil'
```

Explicação:

```text
Esta demo mostra o impacto das observações locais na Rua do Brasil.
O destino está dentro ou perto da zona penalizada, por isso a geometria pode não mudar, mas o custo aumenta.
```

Resultados:

```text
normal  → 1253.56 m | cost 1253.56 | extra 0.00
morning → 1253.56 m | cost 1428.42 | extra 174.85
evening → 1253.56 m | cost 1542.38 | extra 288.82
weekend → 1253.56 m | cost 1253.56 | extra 0.00
```

Frase para dizer:

```text
Aqui a rota mantém a distância, mas o custo contextual aumenta. Isto indica que o sistema reconhece que a zona da Rua do Brasil tem maior fluxo nos períodos morning e evening.
```

## 8. Demo 3 — ISEC para Alma Shopping / Estádio

Filtro QGIS:

```sql
"demo_name" = 'Demo 3 - ISEC para Alma Shopping'
```

Explicação:

```text
Esta demo mostra uma zona de circulação média/alta associada ao Alma Shopping e Estádio.
```

Resultados:

```text
normal  → 2201.99 m | cost 2201.99 | extra 0.00
morning → 2201.99 m | cost 2333.58 | extra 131.59
evening → 2201.99 m | cost 2333.58 | extra 131.59
weekend → 2201.99 m | cost 2201.99 | extra 0.00
```

Frase para dizer:

```text
O sistema aumenta o custo nos períodos com maior movimento, mas neste caso não encontra uma alternativa suficientemente melhor para alterar a geometria.
```

## 9. Demo 4 — Portagem para Recinto Queima/Latada

Filtro QGIS:

```sql
"demo_name" = 'Demo 4 - Portagem para Recinto Queima/Latada'
```

Explicação:

```text
Esta demo mostra o impacto de eventos e nightlife.
A rota é curta, mas o custo aumenta muito no evening e weekend.
```

Resultados:

```text
normal  → 272.12 m | cost 272.12 | extra 0.00
morning → 272.12 m | cost 272.12 | extra 0.00
evening → 272.12 m | cost 460.40 | extra 188.28
weekend → 272.12 m | cost 456.85 | extra 184.73
```

Frase para dizer:

```text
Mesmo sendo uma rota curta, o custo aumenta porque o trajeto passa perto de uma zona associada a eventos académicos e nightlife.
```

## 10. Query de Validação no PostgreSQL

Durante a apresentação, pode ser útil mostrar a query:

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

Explicação:

```text
Esta query compara distância física, custo contextual e custo extra causado pelo contexto.
```

## 11. Query para Mostrar Estradas Penalizadas

```sql
SELECT
    r.id AS road_id,
    r.highway,
    r.length_meters,
    r.cost_normal,
    r.cost_evening,
    ROUND((r.cost_evening / NULLIF(r.cost_normal, 0))::numeric, 2) AS penalty_factor
FROM route_results rr
JOIN roads r
ON ST_Intersects(rr.geom, r.geom)
WHERE rr.route_name ILIKE '%evening%'
  AND r.cost_evening > r.cost_normal
ORDER BY penalty_factor DESC, r.cost_evening DESC
LIMIT 30;
```

Explicação:

```text
Esta query mostra quais segmentos da rede viária foram penalizados na rota evening.
```

## 12. Demonstração do MerginMaps

Mostrar o projeto mobile ou screenshot.

Explicar:

```text
O MerginMaps foi usado para publicar uma versão simplificada do projeto QGIS.
Esta versão permite recolher pontos de contexto no terreno.
Os pontos recolhidos podem depois ser sincronizados e usados no QGIS.
```

Camadas relevantes para mobile:

```text
context_reports
crowded_zones
urban_events
route_request_origins
route_request_destinations
urban_study_area
base map
```

Frase para dizer:

```text
A componente mobile permite que novas observações locais sejam adicionadas ao sistema, reforçando a ideia de plataforma colaborativa e sensível ao contexto.
```

## 13. Roteiro Resumido para a Demo Live

Sequência recomendada:

```text
1. Abrir QGIS.
2. Mostrar organização das camadas.
3. Mostrar crowded_zones e context_reports.
4. Mostrar route_results.
5. Filtrar Demo 1 — ISEC para Portagem.
6. Explicar normal vs evening.
7. Filtrar Demo 2 — ISEC para Rua do Brasil.
8. Explicar aumento de custo sem mudança de geometria.
9. Filtrar Demo 4 — Portagem para Recinto.
10. Explicar eventos/noite.
11. Mostrar query de comparação no PostgreSQL.
12. Mostrar MerginMaps ou screenshot do projeto mobile.
13. Concluir com limitações e trabalho futuro.
```

## 14. Frase Central da Apresentação

```text
O sistema converte observações locais, eventos urbanos e zonas de maior fluxo em penalizações nos segmentos da rede viária. Essas penalizações atualizam os custos usados pelo pgRouting, permitindo gerar rotas alternativas sensíveis ao contexto temporal.
```

## 15. Frase Final

```text
Este projeto demonstra uma aplicação prática de Ambient Intelligence, na qual o sistema adapta o cálculo da rota ao contexto urbano e temporal, apoiando decisões de mobilidade em Coimbra.
```

## 16. Possíveis Perguntas e Respostas

### Pergunta: Porque é que algumas rotas não mudam de geometria?

Resposta:

```text
Porque o pgRouting escolhe sempre a rota com menor custo acumulado. Em alguns casos, mesmo com penalizações, a rota original continua a ser a melhor alternativa. Nesses casos, a geometria mantém-se, mas o custo contextual aumenta.
```

### Pergunta: As penalizações são reais?

Resposta:

```text
As penalizações foram definidas com base em observações locais e regras simples. O objetivo é demonstrar a lógica de adaptação ao contexto. Futuramente poderiam ser substituídas por dados reais de trânsito ou sensores.
```

### Pergunta: Porque usar PostGIS e pgRouting?

Resposta:

```text
PostGIS permite armazenar e analisar dados espaciais, enquanto pgRouting permite calcular caminhos sobre uma rede viária modelada como grafo. Juntos, permitem integrar contexto urbano diretamente no cálculo das rotas.
```

### Pergunta: Qual é a ligação com Ambient Intelligence?

Resposta:

```text
A ligação está na adaptação automática ao contexto. O sistema altera o comportamento do cálculo de rotas conforme o período temporal, eventos e observações locais, sem depender apenas de uma rota estática.
```

### Pergunta: Que dados são sensíveis?

Resposta:

```text
O projeto não recolhe dados pessoais identificáveis. Os pontos são observações urbanas e não trajetos individuais de utilizadores. Mesmo assim, a localização deve ser tratada com cuidado, evitando associar dados a pessoas específicas.
```
