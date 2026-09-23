class CreateSubjectSubjectPrerequisites < ActiveRecord::Migration[8.1]
  def change
    create_table :subject_subject_prerequisites do |t|
      t.references :subject, null: false, foreign_key: { to_table: :subject_subjects }
      t.references :prerequisite, null: false, foreign_key: { to_table: :subject_subjects }

      t.timestamps
    end
  end
end
