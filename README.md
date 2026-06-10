# Sistema Inteligente de Recomendação de Rotas Sensível ao Tempo para Coimbra

Projeto desenvolvido no âmbito da unidade curricular **Ambient Intelligence**, do Mestrado em Engenharia Informática, seguindo o **Perfil 1 — GeoSensing & Community Hub**.

## 1. Objetivo do Projeto

Este projeto implementa um sistema de informação geográfica para a cidade de Coimbra, com foco na recomendação de rotas urbanas sensíveis ao contexto temporal.

O sistema permite calcular rotas entre uma origem e um destino considerando não apenas a distância física, mas também fatores contextuais como:

* fluxo de trânsito observado localmente;
* zonas com maior concentração de pessoas ou veículos;
* eventos urbanos e académicos;
* períodos temporais específicos, como manhã, fim da tarde e noite/eventos.

A lógica central consiste em transformar observações urbanas e dados contextuais em penalizações aplicadas à rede viária. Essas penalizações são usadas pelo `pgRouting` para gerar rotas com menor custo acumulado em diferentes períodos do dia.

## 2. Ideia Principal

Uma rota tradicional considera normalmente apenas distância ou tempo estático. Neste projeto, a rede viária possui diferentes custos:

* `cost_normal` — custo base, associado ao comprimento da estrada;
* `cost_morning` — custo ajustado para fluxos antes das 08:00;
* `cost_evening` — custo ajustado para o período entre 16:30 e 18:30;
* `cost_weekend` — custo ajustado para eventos, noite ou fim de semana.

Assim, a mesma origem e destino podem gerar rotas diferentes dependendo do contexto temporal.

Exemplo:

* rota normal: caminho mais curto;
* rota de fim da tarde: evita zonas com fluxo elevado sempre que exista alternativa;
* rota de evento/noite: considera zonas de maior ocupação associadas a eventos urbanos.

## 3. Tecnologias Utilizadas

O projeto utiliza as seguintes tecnologias:

* **QGIS** — visualização, edição e análise espacial;
* **PostgreSQL** — sistema de gestão de base de dados;
* **PostGIS** — extensão espacial para tratamento de geometrias;
* **pgRouting** — cálculo de rotas sobre a rede viária;
* **Python / PyQGIS** — automação de criação e manipulação de camadas;
* **MerginMaps** — recolha e sincronização de pontos em contexto mobile;
* **OpenStreetMap** — fonte base da rede viária e mapa de fundo;
* **GeoPDF** — exportação cartográfica do projeto.

## 4. Funcionalidades Implementadas

O projeto inclui:

* projeto QGIS organizado por grupos de camadas;
* rede viária de Coimbra representada como grafo;
* pontos de contexto urbano (`context_reports`);
* zonas congestionadas ou de maior fluxo (`crowded_zones`);
* eventos urbanos/académicos (`urban_events`);
* custos dinâmicos na tabela `roads`;
* tabela de penalizações contextuais (`road_context_penalties`);
* cálculo de rotas com `pgRouting`;
* geração de rotas `normal`, `morning`, `evening` e `weekend`;
* tabela final de resultados (`route_results`);
* projeto mobile simplificado para MerginMaps;
* apresentação final com screenshots e demonstração live.

## 5. Estrutura do Repositório

```text
ami-smart-routes-coimbra/
│
├── README.md
│
├── docs/
│   ├── TECHNICAL_GUIDE.md
│   ├── LIVE_DEMO_GUIDE.md
│   └── presentation_assets/
│
├── sql/
│   ├── 01_schema/
│   ├── 02_context/
│   ├── 03_dynamic_routing/
│   └── 99_old/
│
├── qgis/
│   └── projetos QGIS e ficheiros relacionados
│
├── Mobile/
│   └── projeto simplificado para MerginMaps
│
├── Demo/
│   └── ficheiros de demonstração e resultados
│
├── python/
│   └── scripts PyQGIS / consola QGIS
│
└── presentation/
    ├── ModeloApresentacao.pptx
    ├── apresentacao_final_ami_smart_routes.pptx
    └── arquitetura_da_solucao.png
```

## 6. Camadas Principais no QGIS

O projeto QGIS está organizado em grupos de camadas:

```text
01_Base_Map
02_Study_Area
03_Input_Data
04_Request_Points
05_Context_and_Events
06_Routing_Results
```

As camadas principais são:

* `roads` — rede viária usada pelo pgRouting;
* `context_reports` — pontos de contexto, perigo, trânsito, transporte e nightlife;
* `crowded_zones` — polígonos com níveis de concentração baixa, média e alta;
* `urban_events` — eventos académicos e urbanos relevantes;
* `route_results` — rotas calculadas para diferentes períodos;
* `route_request_origins` — pontos de origem definidos pelo utilizador;
* `route_request_destinations` — pontos de destino definidos pelo utilizador.

## 7. Base de Dados Espacial

A base de dados utilizada chama-se:

```text
smart_routes
```

As principais tabelas são:

```text
roads
context_reports
crowded_zones
urban_events
road_context_penalties
roads_vertices_pgr
route_results
```

A tabela `roads` contém a rede viária e os custos usados para o cálculo das rotas:

```text
cost_normal
cost_morning
cost_evening
cost_weekend
```

A tabela `road_context_penalties` relaciona zonas/pontos de contexto com segmentos da rede viária, indicando o fator de penalização aplicado a cada estrada.

A tabela `route_results` guarda as rotas finais geradas para as demonstrações.

## 8. Lógica de Roteamento Dinâmico

O sistema funciona da seguinte forma:

```text
1. As observações locais e zonas de contexto são inseridas no QGIS/PostGIS.
2. As estradas que intersectam zonas congestionadas ou estão próximas de pontos de contexto recebem penalizações.
3. Essas penalizações atualizam os custos temporais da tabela roads.
4. A função create_dynamic_route() escolhe a coluna de custo adequada.
5. O pgRouting calcula a rota com menor custo acumulado.
6. O resultado é guardado em route_results e visualizado no QGIS.
```

Tipos de rota:

```text
normal  → usa cost_normal
morning → usa cost_morning
evening → usa cost_evening
weekend → usa cost_weekend
```

## 9. Demonstrações Criadas

Foram preparadas quatro demonstrações principais:

```text
Demo 1 — ISEC → Rotunda da Portagem
Demo 2 — ISEC → Rua do Brasil
Demo 3 — ISEC → Alma Shopping / Estádio
Demo 4 — Rotunda da Portagem → Recinto Queima/Latada
```

Cada demonstração possui quatro versões:

```text
normal
morning
evening
weekend
```

No total foram geradas 16 rotas.

## 10. Exemplo de Resultado

A tabela de comparação das rotas mostra:

* distância física da rota;
* custo contextual;
* custo adicional causado pelo contexto urbano.

Exemplo de interpretação:

```text
A rota evening pode ter uma distância ligeiramente superior à rota normal,
mas é escolhida porque o sistema considera penalizações associadas a zonas
de maior fluxo no final da tarde.
```

Em algumas demonstrações, a geometria da rota muda. Noutras, a rota mantém o mesmo trajeto, mas o custo aumenta, indicando que o destino ou o percurso atravessa uma zona penalizada.

## 11. MerginMaps

Foi criado um projeto QGIS simplificado para utilização em ambiente mobile com MerginMaps.

Objetivos do projeto mobile:

* recolher pontos de contexto no terreno;
* permitir a edição de `context_reports`;
* consultar zonas e eventos urbanos;
* sincronizar os dados recolhidos com o projeto QGIS desktop.

Este componente demonstra a vertente colaborativa e móvel do projeto.

## 12. Como Executar / Reproduzir

De forma geral, para reproduzir o projeto:

1. Abrir a base de dados PostgreSQL/PostGIS `smart_routes`;
2. Confirmar que as extensões `postgis` e `pgrouting` estão ativas;
3. Carregar/importar as tabelas espaciais;
4. Executar os scripts SQL da pasta `sql/`;
5. Abrir o projeto QGIS presente na pasta `qgis/`;
6. Carregar a tabela `route_results` no QGIS;
7. Aplicar simbologia por `route_type`;
8. Usar filtros por `demo_name` para apresentar cada demonstração.

## 13. Apresentação Final

A apresentação está dividida em duas partes:

1. **Slides explicativos**, com arquitetura, dados, lógica, código e resultados;
2. **Demonstração live no QGIS**, mostrando as rotas, filtros, camadas e integração com MerginMaps.

A demonstração principal é:

```text
Demo 1 — ISEC → Rotunda da Portagem
```

porque mostra uma alteração real da geometria da rota no período `evening`.

## 14. Conclusão

O projeto demonstra uma aplicação prática de Ambient Intelligence, onde o sistema adapta o cálculo de rotas ao contexto urbano e temporal.

A contribuição principal é transformar dados espaciais, observações locais e eventos urbanos em custos dinâmicos usados pelo `pgRouting`, permitindo gerar rotas alternativas para diferentes momentos do dia.

O sistema é simples, extensível e pode futuramente ser melhorado com dados reais de trânsito em tempo real, sensores urbanos ou modelos de aprendizagem automática.
