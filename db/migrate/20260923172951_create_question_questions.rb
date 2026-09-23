class CreateQuestionQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :question_questions do |t|
      t.text :titulo

      t.timestamps
    end
  end
end
