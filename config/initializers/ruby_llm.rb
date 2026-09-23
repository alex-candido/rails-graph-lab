ruby_llm_config = Rails.application.config_for(:ruby_llm)

RubyLLM.configure do |config|
  config.gemini_api_key = ruby_llm_config[:gemini_api_key]
  config.default_model  = ruby_llm_config[:default_model]
  config.logger         = Rails.logger
end
