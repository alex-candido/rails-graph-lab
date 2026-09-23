# Embrulha UMA chamada de agente — mesmo papel do DataExtraction::Step do
# Fabi real, adaptado (aqui loga em Rails.logger em vez de process.logs,
# já que esse laboratório não tem um model de processo).
class Step
  attr_reader :output

  def initialize(description:, agent: nil)
    @description  = description
    @agent        = agent
    @is_completed = false
    @is_failed    = false
  end

  def execute_agent(ask:, context: nil)
    unless @agent.present?
      failed!("Nenhum agente associado a esta etapa.")
      return self
    end

    context&.compact&.each do |ctx|
      content = ctx.is_a?(Hash) ? ctx.to_json : ctx
      @agent.add_message({ role: "user", content: content })
    end

    attach_callbacks(@agent)
    result = @agent.ask(ask)
    raise @output if failed?

    complete!(result.content)
    self
  end

  def completed? = @is_completed
  def failed?    = @is_failed

  private

  def complete!(output)
    @output       = output
    @is_completed = true
  end

  def failed!(error)
    @output    = error
    @is_failed = true
  end

  def attach_callbacks(agent)
    agent.on_tool_call do |tool_call|
      Rails.logger.info("→ Chamando ferramenta: #{tool_call.name} (#{@description})")
    end

    agent.on_tool_result do |result|
      if result.is_a?(RubyLLM::Tool::Halt)
        Rails.logger.warn("✗ Ferramenta interrompeu: #{result.content}")
        failed!("Processo interrompido: #{result.content}")
      else
        Rails.logger.info("✓ Ferramenta executada com sucesso.")
      end
    end
  end
end
