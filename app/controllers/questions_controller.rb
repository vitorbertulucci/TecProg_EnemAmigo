# Class: questions_controller.rb.
# Purpose: this class control the actions of questions, like add or delete questions.
# Enem Amigo.
# FGA - Universidade de Brasíilia UnB.

class QuestionsController < ApplicationController

  # Checks for user logged in.
  before_action :authenticate_use
  before_action :authenticate_admin, only: [ :new, :create, :edit, :destroy, :update ]

  include QuestionsHelper

  # Name: index.
	# Objective: this method organizes issues per year and number.
	# Parameters: year and number.
	# Return: questions.

  def index

    @questions = Question.all.order(:year, :number)
    return @questions

  end

  # Name: edit.
	# Objective: this method find the question.
	# Parameters: question identifier.
	# Return: question.

  def edit

    @question = Question.find(params[:id])
    return @question

  end

  # Name: update.
  # Objective: this method allows editing questions.
  # Parameters: question identifier.
  # Return: redirect to the question.

  def update

    @question = Question.find(params[:id])

    if (@question.update_attributes(question_params))
      flash[:success] = "Questão atualizada com sucesso!"

      return redirect_to question_path

    else

      return render 'edit'

    end
  end

  # Name: show.
	# Objective: this method find a question by identifier to show.
	# Parameters: question identifier.
	# Return: question.

  def show

    @question = Question.find(params[:id])
    return @question

  end

  # Name: destroy.
	# Objective: this method deletes the selected question.
	# Parameters: question identifier.
	# Return: redirect to the questions page.

  def destroy

    @question = Question.find(params[:id])
    @question.destroy
    flash[:success] = "Questão deletada com sucesso!"

    return redirect_to questions_path

  end

  # Name: answer.
	# Objective: this method verify if the question is right or wrong.
	# Parameters: question identifier, alternative answer.
	# Return: nothing.

  def answer
    question = Question.find(params[:id])
    @answer_letter = params[:alternative]

    if (params[:alternative].blank?)

      return redirect_to_back(root_path)

    else
      current_user.update_attribute(:tried_questions, current_user.tried_questions << question.id)
      question.update_attribute(:users_tries, question.users_tries + 1)

      @correct_answer = (@answer_letter == question.right_answer)

      respond_to do |format|
        format.html { redirect_to questions_path }
        format.js { @correct_answer }

      end

      if (@correct_answer)
          question.update_attribute(:users_hits, question.users_hits + 1)
          unless current_user.accepted_questions.include? question.id
              current_user.accepted_questions.push(question.id)
              current_user.update_attribute(:points, current_user.points + 4)

          end
      else
        # nothing to do
      end

    end

  end

  # Name: category.
	# Objective: don't have.
	# Parameters: don't have parameters.
	# Return: nothing.

  def category

  end

  # Name: nature.
	# Objective: this method allocates the question in "natural sciences".
	# Parameters: don't have parameters.
	# Return: questions.

  def nature

    @questions = Question.where(area: "ciências da natureza e suas tecnologias").order(:year, :number)
    return @questions

  end

  # Name: humans.
	# Objective: this method allocates the question in "humans sciences".
	# Parameters: don't have parameters.
	# Return: questions.

  def humans

    @questions = Question.where(area: "ciências humanas e suas tecnologias").order(:year, :number)
    return @questions

  end

  # Name:languages.
	# Objective: this method allocates the question in "languages".
	# Parameters: don't have parameters.
	# Return: questions.

  def languages

    @questions = Question.where(area: "linguagens, códigos e suas tecnologias").order(:year, :number)
    return @questions

  end

  # Name: math.
	# Objective: this method allocates the question in "math".
	# Parameters: don't have parameters.
	# Return: questions.

  def math

    @questions = Question.where(area: "matemática e suas tecnologias").order(:year, :number)
    return @questions

  end

  # Name: recommended.
	# Objective: this method instantiates allocates the questions by classification in area.
	# Parameters: don't have parameters.
	# Return: questions.

  def recommended

    areas = ["ciências da natureza e suas tecnologias",
             "ciências humanas e suas tecnologias",
             "linguagens, códigos e suas tecnologias",
             "matemática e suas tecnologias"]
    @questions = []
    areas.each do |area|
      classification = current_user.classification(area)
      @questions = @questions | instance_eval("Question.#{classification}_questions('#{area}')")
    end
    @questions = @questions.select { |q| !current_user.accepted_questions.include? q.id }

    return @questions

  end

  # Name: upload_questions.
	# Objective: this method updates the questions.
	# Parameters: questions file.
	# Return: redirects to the questions page.

  def upload_questions

    uploaded_file = params[:questions_file]
    raise Exception if uploaded_file.nil?
    file_content = uploaded_file.read
    Parser.read_questions(file_content)
    flash[:success] = "Questões armazenadas com sucesso."

    return redirect_to questions_path

  end

  # Name: upload_candidates_data.
	# Objective: this method updates the candidates.
	# Parameters: don't have parameters.
	# Return: redirects to the previous page.

  def upload_candidates_data

    uploaded_file = params[:candidates_data_file]
    raise Exception if uploaded_file.nil?
    file_content = uploaded_file.read
    Parser.read_candidates_data(file_content, params[:test_year])
    flash[:success] = "Dados armazenados com sucesso."

    return redirect_to questions_path

  end

  # Name: next_question.
	# Objective: this method redirect to the next question.
	# Parameters: question identifier.
	# Return: next question.

  def next_question

    return redirect_to Question.find(params[:id]).next_question

  end

  private

  # Name: question_params.
	# Objective:
	# Parameters: year, area, number, enunciation, reference, image, right_answer,
  #             alternatives attributes identifier, alternatives attributes letter,
  #             alternatives attributes description.
	# Return: nothing.

  def question_params

    params.require(:question).permit(:year,:area,:number,:enunciation,:reference,:image,:right_answer,
    :alternatives_attributes => [:id, :letter, :description])

  end

end
