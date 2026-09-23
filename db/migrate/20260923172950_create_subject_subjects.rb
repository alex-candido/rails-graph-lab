class CreateSubjectSubjects < ActiveRecord::Migration[8.1]
  def change
    create_table :subject_subjects do |t|
      t.string :nome

      t.timestamps
    end
  end
end
