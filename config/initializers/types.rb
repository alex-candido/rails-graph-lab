# config/initializers/types.rb

require 'apache_age/types/factory'
# AGE Type Definition Usage (edges/nodes):
# require_dependency 'company'
# ActiveModel::Type.register(
#   :company, ApacheAge::Types::Factory.type_for(Company)
# )

Rails.application.config.to_prepare do
  # Register AGE types
  require_dependency 'apache_age/node'
  ActiveModel::Type.register(
    :node, ApacheAge::Types::Factory.type_for(ApacheAge::Node)
  )

  require_dependency 'apache_age/edge'
  ActiveModel::Type.register(
    :edge, ApacheAge::Types::Factory.type_for(ApacheAge::Edge)
  )

  require_dependency 'graph/question'
  ActiveModel::Type.register(
    :question, ApacheAge::Types::Factory.type_for(Graph::Question)
  )
  require_dependency 'graph/subject'
  ActiveModel::Type.register(
    :subject, ApacheAge::Types::Factory.type_for(Graph::Subject)
  )
  require_dependency 'graph/has_subject'
  ActiveModel::Type.register(
    :has_subject, ApacheAge::Types::Factory.type_for(Graph::HasSubject)
  )
  require_dependency 'graph/requires'
  ActiveModel::Type.register(
    :requires, ApacheAge::Types::Factory.type_for(Graph::Requires)
  )
end