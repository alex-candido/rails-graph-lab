FactoryBot.define do
  factory :subject_subject, class: "Subject::Subject" do
    sequence(:nome) { |n| "Assunto #{n}" }
  end
end
