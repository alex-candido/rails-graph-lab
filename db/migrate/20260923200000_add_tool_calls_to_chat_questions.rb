class AddToolCallsToChatQuestions < ActiveRecord::Migration[8.1]
  def change
    add_column :chat_questions, :tool_calls, :jsonb, null: false, default: []
  end
end
