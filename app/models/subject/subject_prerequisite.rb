# == Schema Information
#
# Table name: subject_subject_prerequisites
#
#  id              :bigint           not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  prerequisite_id :bigint           not null
#  subject_id      :bigint           not null
#
# Indexes
#
#  index_subject_subject_prerequisites_on_prerequisite_id  (prerequisite_id)
#  index_subject_subject_prerequisites_on_subject_id       (subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (prerequisite_id => subject_subjects.id)
#  fk_rails_...  (subject_id => subject_subjects.id)
#
class Subject::SubjectPrerequisite < ApplicationRecord
  belongs_to :subject, class_name: "Subject::Subject"
  belongs_to :prerequisite, class_name: "Subject::Subject"
end
