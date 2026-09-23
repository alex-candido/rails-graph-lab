class ChatsController < ApplicationController
  def new
    @subjects_count = Subject::Subject.count
    @questions_count = Question::Question.count
  end
end
