# Consulta o grafo (Apache AGE) sem nenhum LLM aqui dentro — 100% Ruby
# determinístico, mesmo espírito das tools de matching do Fabi de verdade
# (ex.: MatchQuestionsMetadataTool). O agente decide QUANDO chamar; essa
# tool só faz a travessia e devolve dado bruto.
class GraphTraversalTool < ApplicationTool
  description "Busca no grafo de conhecimento a cadeia de pré-requisito de um assunto e as questões associadas a cada assunto encontrado"

  PREREQUISITE_DEPTH = "1..5"
  DIRECT_EDGE_DEPTH   = "1..1"

  param :subject_name, type: "string", desc: "Nome do assunto a partir do qual buscar pré-requisitos (deve bater com o nome de um assunto existente no grafo)"

  def execute(subject_name:)
    subject = Graph::Subject.find_by(nome: subject_name)
    return RubyLLM::Tool::Halt.new("Assunto '#{subject_name}' não encontrado no grafo.") unless subject

    prerequisite_names = prerequisite_chain(subject_name)
    subject_names = [ subject_name ] + prerequisite_names

    {
      assunto: subject_name,
      cadeia_de_prerequisito: prerequisite_names,
      questoes_por_assunto: subject_names.index_with { |nome| questions_for(nome) }
    }
  rescue => e
    RubyLLM::Tool::Halt.new("Erro ao consultar o grafo: #{e.message}")
  end

  private

  def prerequisite_chain(subject_name)
    ApacheAge::Path.cypher(
      path_edge: Graph::Requires,
      path_length: PREREQUISITE_DEPTH,
      start_node_filter: { nome: subject_name }
    ).all.flat_map { |path| path.select { |item| item.is_a?(Graph::Subject) }.map(&:nome) }.uniq - [ subject_name ]
  end

  def questions_for(subject_name)
    ApacheAge::Path.cypher(
      path_edge: Graph::HasSubject,
      path_length: DIRECT_EDGE_DEPTH,
      end_node_filter: { nome: subject_name }
    ).all.filter_map { |path| path.find { |item| item.is_a?(Graph::Question) }&.titulo }
  end
end
