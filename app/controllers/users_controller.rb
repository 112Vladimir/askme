class UsersController < ApplicationController
  def index
  end

  def new
  end

  def edit
  end

  def show
    @user = User.new(
        id: 1,
        name: 'Vladimir',
        username: '112Vladimir',
        avatar_url:'https://okotikah.ru/wp-content/uploads/2019/01/samya-umnaya-koshka.png'
    )

    @questions = [
        Question.new(text: 'How are you?', created_at: Date.parse('07.08.2019')),
    Question.new(text: 'What are you doing?', created_at: Date.parse('07.08.2019')),
    ]

    @new_question = Question.new
  end
end
