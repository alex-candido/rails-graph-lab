FactoryBot.define do
  factory :question_question, class: "Question::Question" do
    sequence(:titulo) { |n| "Questão #{n}" }
  end
end
