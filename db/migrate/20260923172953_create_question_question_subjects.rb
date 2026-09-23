class CreateQuestionQuestionSubjects < ActiveRecord::Migration[8.1]
  def change
    create_table :question_question_subjects do |t|
      t.references :question, null: false, foreign_key: { to_table: :question_questions }
      t.references :subject, null: false, foreign_key: { to_table: :subject_subjects }

      t.timestamps
    end
  end
end
