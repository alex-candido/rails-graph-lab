class AddApacheAge < ActiveRecord::Migration[7.1]
  def up
    # Allow age extension
    execute('CREATE EXTENSION IF NOT EXISTS age;')

    # Load the age code
    execute("LOAD 'age';")

    # Load the ag_catalog into the search path
    execute('SET search_path = ag_catalog, "$user", public;')

    # Create age_schema graph if it doesn't exist
    execute("SELECT create_graph('age_schema');")

    # Restaura a ordem do search_path da conexão (público primeiro) pro resto
    # desta sessão de migrate — sem isso, toda migration que rodar depois desta
    # (na mesma execução de `db:migrate`) cria suas tabelas dentro de ag_catalog
    # em vez de public, porque o Postgres usa o primeiro schema do search_path
    # como destino padrão de CREATE TABLE sem schema explícito.
    execute('SET search_path = public, ag_catalog, age_schema;')
  end

  def down
    execute <<-SQL
      DO $$
      BEGIN
        IF EXISTS (
          SELECT 1
          FROM pg_constraint
          WHERE conname = 'fk_graph_oid'
        ) THEN
          ALTER TABLE ag_catalog.ag_label
          DROP CONSTRAINT fk_graph_oid;
        END IF;
      END $$;
    SQL

    execute("SELECT drop_graph('age_schema', true);")
    execute('DROP SCHEMA IF EXISTS ag_catalog CASCADE;')
    execute('DROP EXTENSION IF EXISTS age;')
  end
end
