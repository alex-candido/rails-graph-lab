# Sem view ainda de propósito — responde só JSON, pra testar o ciclo
# assíncrono (create dispara o job, show consulta o resultado depois) sem
# precisar de nenhuma tela.
class Chat::QuestionsController < ApplicationController
  def create
    @chat_question = Chat::Question.create!(question: params[:question])
    @chat_question.update!(status: :processing)

    render json: serialize(@chat_question), status: :created
  end

  def show
    @chat_question = Chat::Question.find(params[:id])

    render json: serialize(@chat_question)
  end

  private

  def serialize(chat_question)
    chat_question.as_json(only: [ :id, :question, :status, :resposta, :assuntos_consultados, :erro ])
  end
end
