class ChatsController < ApplicationController
  def new
  end

  def create
    @question = params[:question]

    begin
      @result = GraphRagWorkflow.new(@question).call
    rescue => e
      @error = e.message
    end

    render :new
  end
end
