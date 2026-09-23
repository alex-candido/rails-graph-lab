class GraphAnsweringAgent < RubyLLM::Agent
  chat_model RubyLLM::Chat
  instructions
  tools [ GraphTraversalTool ]
  inputs :question

  schema do
    string :resposta
    array :assuntos_consultados do
      string
    end
  end
end
