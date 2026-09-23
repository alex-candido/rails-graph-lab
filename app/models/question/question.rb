# == Schema Information
#
# Table name: question_questions
#
#  id         :bigint           not null, primary key
#  titulo     :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Question::Question < ApplicationRecord
  include SyncsToGraph

  has_many :question_subjects, dependent: :destroy
  has_many :subjects, through: :question_subjects

  validates :titulo, presence: true
end
