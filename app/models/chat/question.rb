# == Schema Information
#
# Table name: chat_questions
#
#  id                   :bigint           not null, primary key
#  assuntos_consultados :text
#  erro                 :text
#  question             :text             not null
#  resposta             :text
#  status               :integer          default(0), not null
#  tool_calls           :jsonb            not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
class Chat::Question < ApplicationRecord
  enum :status, [ :pending, :processing, :completed, :failed ], default: :pending

  validates :question, presence: true

  after_save :execute_answering, if: -> { saved_change_to_status? && processing? }

  private

  def execute_answering
    Chat::AnswerQuestionJob.perform_later(chat_question: self)
  end
end
