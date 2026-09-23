FactoryBot.define do
  factory :question_question_subject, class: "Question::QuestionSubject" do
    association :question, factory: :question_question
    association :subject, factory: :subject_subject
  end
end
