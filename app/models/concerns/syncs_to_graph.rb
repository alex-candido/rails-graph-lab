# Mesmo padrão do Subject#enqueue_name_embedding no Fabi real: nunca fazer
# trabalho de sincronização (aqui, com o grafo) dentro do ciclo de
# request/response — sempre via job assíncrono.
module SyncsToGraph
  extend ActiveSupport::Concern

  included do
    after_commit :enqueue_graph_sync, on: [ :create, :update, :destroy ]
  end

  class_methods do
    # Suspende o disparo automático de job pra carga em lote (ex.: seed) —
    # criar dezenas de registro em sequência dispararia dezenas de jobs
    # concorrentes, cada um segurando uma conexão do pool enquanto espera o
    # lock do GraphSync, estourando o pool antes do lote terminar. Uso
    # normal (uma edição por vez, fora de um lote) continua dispersando o
    # job automaticamente.
    def suppress_graph_sync
      previous = Thread.current[:suppress_graph_sync]
      Thread.current[:suppress_graph_sync] = true
      yield
    ensure
      Thread.current[:suppress_graph_sync] = previous
    end
  end

  private

  def enqueue_graph_sync
    return if Thread.current[:suppress_graph_sync]

    GraphSyncJob.perform_later
  end
end
