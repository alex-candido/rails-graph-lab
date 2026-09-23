class GraphSyncJob < ApplicationJob
  queue_as :default

  def perform
    GraphSync.call
  end
end
