# fabi-graph-lab

Laboratório separado do Fabi — spike de banco de grafos (Apache AGE) rodando
junto com pgvector no mesmo Postgres, pra validar viabilidade antes de trazer
essa decisão pro projeto principal.

## Subir o ambiente

```bash
docker compose up -d --build   # Postgres 17 + AGE + pgvector (+ PostGIS disponível, desligado por padrão)
bin/rails db:migrate
```

## ⚠️ Reset de banco: sempre apague o `db/schema.rb` antes

Desde o Rails 7.1, `db:migrate` num banco **totalmente vazio** carrega o
`db/schema.rb` direto em vez de rodar as migrations uma a uma (atalho de
performance). Esse atalho **quebra com o Apache AGE**: a extensão cria o
schema `ag_catalog` como efeito colateral de `CREATE EXTENSION age`, mas o
`schema.rb` declara a extensão como `ag_catalog.age` — tentando usar o schema
antes dele existir (`PG::InvalidSchemaName: schema "ag_catalog" does not exist`).

Rodar as migrations uma por uma (o caminho normal, sem atalho) sempre funciona.
Pra garantir isso num reset completo:

```bash
rm -f db/schema.rb
bin/rails db:drop db:create db:migrate
```

Isso não afeta o dia a dia (adicionar uma migration nova com o banco já
populado funciona normal) — só importa quando o banco está **vazio do zero**.

## Extensões instaladas

- `age` (Apache AGE — grafo, Cypher)
- `vector` (pgvector — busca semântica)
- PostGIS disponível na imagem, mas **não ativado** por padrão (não faz parte
  do escopo do spike) — pra ativar, adicione `CREATE EXTENSION postgis;` numa
  migration.

## Organização dos models

- `Graph::*` (`app/nodes/`, `app/edges/`) — nós e arestas do grafo (Apache AGE,
  via gem `rails_age`).
- `Question::*`, `Subject::*` (`app/models/`) — models relacionais normais
  (fonte da verdade), no mesmo padrão de namespace + `table_name_prefix` do
  Fabi de verdade (`question_questions`, `subject_subjects`, etc.).
