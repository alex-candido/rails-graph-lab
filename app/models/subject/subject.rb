# == Schema Information
#
# Table name: subject_subjects
#
#  id         :bigint           not null, primary key
#  nome       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Subject::Subject < ApplicationRecord
  has_many :subject_prerequisites, class_name: "Subject::SubjectPrerequisite", dependent: :destroy
  has_many :prerequisites, through: :subject_prerequisites

  has_many :inverse_subject_prerequisites, class_name: "Subject::SubjectPrerequisite",
    foreign_key: :prerequisite_id, dependent: :destroy
  has_many :dependents, through: :inverse_subject_prerequisites, source: :subject

  has_many :question_subjects, class_name: "Question::QuestionSubject", dependent: :destroy
  has_many :questions, through: :question_subjects

  validates :nome, presence: true, uniqueness: true
end
