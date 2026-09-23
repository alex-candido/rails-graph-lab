# Consulta o grafo (Apache AGE) sem nenhum LLM aqui dentro — 100% Ruby
# determinístico, mesmo espírito das tools de matching do Fabi de verdade
# (ex.: MatchQuestionsMetadataTool). O agente decide QUAL relação, DE ONDE
# e QUÃO FUNDO buscar (via function calling); essa tool só executa a
# travessia e devolve dado bruto — nunca decide nada sozinha.
class GraphTraversalTool < ApplicationTool
  description "Percorre o grafo de conhecimento a partir de um nó, seguindo um tipo de relação específico, até uma profundidade determinada"

  # Allowlist de relações permitidas — mesmo princípio do
  # DockerRunner::COMMANDS: nunca deixar o agente apontar pra uma classe
  # arbitrária.
  EDGE_TYPES = {
    "Requires"   => Graph::Requires,
    "HasSubject" => Graph::HasSubject
  }.freeze

  param :edge_type, type: "string", desc: "Tipo de relação a seguir: 'Requires' (assunto -> pré-requisito) ou 'HasSubject' (questão -> assunto)"
  param :node_name, type: "string", desc: "Nome do assunto (ou título da questão) de onde partir ou onde chegar na busca"
  param :direction,  type: "string", desc: "'from' busca o que node_name aponta (segue a seta a partir dele); 'to' busca o que aponta pra node_name (segue a seta até ele)"
  param :depth,      type: "string", desc: "Profundidade da busca em Cypher, ex: '1..5' pra multi-salto ou '1..1' pra ligação direta", required: false

  def execute(edge_type:, node_name:, direction:, depth: "1..5")
    edge_class = EDGE_TYPES[edge_type]
    return RubyLLM::Tool::Halt.new("Tipo de relação '#{edge_type}' desconhecido. Use um de: #{EDGE_TYPES.keys.join(', ')}.") unless edge_class

    node_filter = direction == "from" ? { start_node_filter: { nome: node_name } } : { end_node_filter: { nome: node_name } }
    paths = ApacheAge::Path.cypher(path_edge: edge_class, path_length: depth, **node_filter).all

    return RubyLLM::Tool::Halt.new("Nenhum caminho encontrado pra '#{node_name}' via '#{edge_type}'.") if paths.empty?

    { edge_type: edge_type, node_name: node_name, direction: direction, caminhos: paths.map { |path| serialize_path(path) } }
  rescue => e
    RubyLLM::Tool::Halt.new("Erro ao consultar o grafo: #{e.message}")
  end

  private

  def serialize_path(path)
    path.filter_map do |item|
      case item
      when Graph::Subject  then { tipo: "Subject", nome: item.nome }
      when Graph::Question then { tipo: "Question", titulo: item.titulo }
      end
    end
  end
end
