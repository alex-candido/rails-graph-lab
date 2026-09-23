# Orquestra o ciclo de GraphRAG — mesmo papel do DataExtraction::MainWorkflow
# do Fabi real. Só uma etapa aqui (um agente + a tool de travessia), sem
# precisar de múltiplos agentes especializados — ver discussão sobre
# Workflow > Step > Agent > Tool.
class GraphRagWorkflow
  def initialize(question)
    @question = question
  end

  def call
    step = Step.new(
      description: "Responder pergunta usando o grafo de conhecimento.",
      agent: GraphAnsweringAgent.new(question: @question)
    )

    step.execute_agent(ask: "Responda a pergunta do usuário utilizando o grafo de conhecimento.")

    raise step.output if step.failed?

    step.output.merge("tool_calls" => step.tool_calls)
  end
end
