# == Schema Information
#
# Table name: question_question_subjects
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  question_id :bigint           not null
#  subject_id  :bigint           not null
#
# Indexes
#
#  index_question_question_subjects_on_question_id  (question_id)
#  index_question_question_subjects_on_subject_id   (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (question_id => question_questions.id)
#  fk_rails_...  (subject_id => subject_subjects.id)
#
class Question::QuestionSubject < ApplicationRecord
  include SyncsToGraph

  belongs_to :question, class_name: "Question::Question"
  belongs_to :subject, class_name: "Subject::Subject"

  validates :question_id, uniqueness: { scope: :subject_id }
end
