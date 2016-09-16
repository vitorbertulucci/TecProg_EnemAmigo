# Class: exams_controller.rb.
# Purpose: This class is designed to control the exams -- answer, result and cancel.
# Enem Amigo.
# FGA - Universidade de Brasíilia UnB.

include ExamsHelper

class ExamsController < ApplicationController

  before_action :authenticate_user

  # Name: select_exam.
  # Objective: this method is used to call the view.
  # Parameters: don't have parameters.
  # Return: nothing.

  def select_exam

  end

  # Name: exams_statistics.
  # Objective: this method is used to call the view.
  # Parameters: don't have parameters.
  # Return: nothing.

  def exams_statistics

  end

  # Name: answer_exam.
  # Objective: this method is used to show questions of selected year.
  # Parameters: :year_exam, :danger.
  # Return: @exam, redirect_to_bac(select_exam_path).

  def answer_exam

    questions = params[:year_exam] ? Question.where(year: params[:year_exam]) : Question.all

    if !questions.empty?
      auxiliar_exam = push_questions_auxiliar(questions)
      @exam = push_questions(auxiliar_exam)
    else
      return redirect_to_back(select_exam_path)
      if params[:year_exam]
        flash[:danger] = "Não há questões cadastradas do ano de #{params[:year_exam]}."
      else
        flash[:danger] = "Não há questões cadastradas."
      end
    end

  end

  # Name: exam_result
  # Objective: this method is used to show the exam result after to answer the questions.
  # Parameters: :exam_id, :exam_performance, :danger.
  # Return: @exam, redirect_to_back.

  def exam_result

    if params[:exam_id]
      @exam = Exam.find(params[:exam_id])
      @exam = fill_user_answers(@exam)

      current_user.exams_total_questions += @exam.questions.count
      current_user.update_attribute(:exam_performance, current_user.exam_performance + [@exam.accepted_answers])

      @exam.save
      @exam.user_answers
    else
      flash[:danger] = "Você deve responder uma prova antes para obter seu resultado."
      return redirect_to_back
    end

  end

  # Name: cancel_exam
  # Objective: this method is used to delete the exam without save the answers.
  # Parameters: :exam_id.
  # Return: redirect_to root_path.

  def cancel_exam

    exam = Exam.find(params[:exam_id])
    exam.destroy
    return redirect_to root_path

  end

end
