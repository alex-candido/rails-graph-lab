FactoryBot.define do
  factory :subject_subject_prerequisite, class: "Subject::SubjectPrerequisite" do
    association :subject, factory: :subject_subject
    association :prerequisite, factory: :subject_subject
  end
end
