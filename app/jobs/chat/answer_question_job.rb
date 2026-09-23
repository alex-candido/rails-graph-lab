class Chat::AnswerQuestionJob < ApplicationJob
  queue_as :default

  def perform(args)
    chat_question = args[:chat_question]

    result = GraphRagWorkflow.new(chat_question.question).call
    chat_question.update!(
      status: :completed,
      resposta: result["resposta"],
      assuntos_consultados: result["assuntos_consultados"].join(", ")
    )
  rescue => e
    chat_question.update!(status: :failed, erro: e.message)
  end
end
