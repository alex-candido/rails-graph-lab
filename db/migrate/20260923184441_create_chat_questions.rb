class CreateChatQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :chat_questions do |t|
      t.text :question, null: false
      t.integer :status, default: 0, null: false
      t.text :resposta
      t.text :assuntos_consultados
      t.text :erro

      t.timestamps
    end
  end
end
