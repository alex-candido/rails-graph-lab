class EnableGraphAndVectorExtensions < ActiveRecord::Migration[8.1]
  def up
    execute "CREATE EXTENSION IF NOT EXISTS vector;"
    execute "CREATE EXTENSION IF NOT EXISTS age;"
  end

  def down
    execute "DROP EXTENSION IF EXISTS vector;"
    execute "DROP EXTENSION IF EXISTS age;"
  end
end
