# Class: battles_controller.rb.
# Purpose: This class is designed to control the actions of battles in the Enem Amigo.
# Enem Amigo.
# FGA - Universidade de Brasília UnB.

class BattlesController < ApplicationController

    include BattlesHelper

    before_action :authenticate_user
    before_action :verify_participation, only: [:show, :destroy]
    before_action :verify_all_played, only: [:result]
    before_action :verify_current_user_played, only: [:finish]

    # Name: new.
    # Objective: this method instantiating the object battle.
    # Parameters: don't have parameters.
    # Return: @battle.

    def new

        # To instance a battle object
        @battle = Battle.new

        return @battle

    end

    # Name: create.
    # Objective: this method create and save a battle.
    # Parameters: don't have parameters.
    # Return: @battle.

    def create

        # To create a new battle.
        @battle = Battle.new(player_1: current_user, player_2: User.where(nickname: params[:player_2_nickname]).first)

        # Add the attribute category to create a new battle object.
        @battle.category = params[:battle][:category]

        # Set generate questions on battle object
        @battle.generate_questions

        # Validate the creation of the object to sent the notification
        if (@battle.save)
            new_battle_notification(@battle)
            flash[:success] = "Convite enviado com sucesso!"
            return redirect_to battles_path
        else
            flash[:danger] = "Usuário não encontrado"
            return render 'new'
        end

        return @battle

    end

    # Name: show the battle.
    # Objective: this method shows a battle.
    # Parameters: don't have parameters.
    # Return: @battle, @adversary, @question.

    def show

        # To seek proper battle to start using your id as parameter.
        @battle = Battle.find(params[:id])
        start_battle(@battle)
        battle_answer_notification(@battle, true) unless is_player_1?(@battle)

        # Check the users in battle.
        @adversary = is_player_1?(@battle) ? @battle.player_2 : @battle.player_1
        @question = @battle.questions[0]

        return @battle
        return @adversary
        return @question

    end

    # Name: index.
    # Objective: this method show the index page.
    # Parameters: don't have parameters.
    # Return: @pending_battles, @waiting_battles, @finished_battles, @battles.

    def index

        @pending_battles = []
        @waiting_battles = []
        @finished_battles = []
        @battles = current_user.battles.reverse
        @battles.each do |battle|
            if (battle.all_played?)
                @finished_battles.push(battle)
            elsif player_started?(battle)
                @waiting_battles.push(battle)
            else
                @pending_battles.push(battle)
            end
        end

        return @pending_battles
        return @waiting_battles
        return @finished_battles
        return @battles

    end

    # Name: destroy.
    # Objective: this method destroy a battle.
    # Parameters: don't have parameters.
    # Return: @battle.

    def destroy

        # To seek proper battle to destroy using your id as parameter.
        @battle = Battle.find(params[:id])
        battle_answer_notification(@battle, false)
        @battle.destroy

        return redirect_to battles_path
        return @battle

    end

    # Name: ranking.
    # Objective: this method orders battles to create the ranking.
    # Parameters: don't have parameters.
    # Return: @users.

    def ranking

        # To order the palyers by wins and battle points.
        @users = User.order(:wins, :battle_points).reverse

        return @users

    end

    # Name: answer_status
    # Objective:
    # Parameters:
    # Return:

    def answer_status

       @answer_letter == true

       # Check the asnwer of question and set this.
       if(question.right_answer == true)
         @answer_letter = true
       else
         @answer_letter = false
       end

    end

    # Name: choose_correct_player
    # Objective:
    # Parameters:
    # Return:

    def choose_correct_player

      player_chosen = is_player_1?(battle)

      if(player_chosen)
          battle.player_1_answers[question_position] = @answer_letter
      else
          battle.player_2_answers[question_position] = @answer_letter
      end

    end

    # Name: update_hits_player
    # Objective:
    # Parameters:
    # Return:

    def update_hits_player

      @correct_answer = answer_status

      # Update the hits of user if the answer of questins was correct.
      if(@correct_answer)
        question.update_attribute(:users_hits, question.users_hits + 1)
      else
        # Nothing to do.
      end

    end

    # Name: save_battle_status
    # Objective:
    # Parameters:
    # Return:

    def save_battle_status

      @answer_letter = params[:alternative]

      # Update and save the hits of player  and battle if the answer was blank.
      if(@answer_letter.blank?)
          question.update_attribute(:users_tries, question.users_tries + 1)

          update_hits_player

          choose_correct_player

          question_position = question_position.succ

          battle.save
      else
        # Nothing to do.
      end

    end

    # Name: answer.
    # Objective: this method shows the answers.
    # Parameters: don't have parameters.
    # Return: @answer_letter, @correct_answer, @question.

    def answer

        # To seek a bttle according to the id.
        battle = Battle.find(params[:id])

        question_position = question_number(battle)

        question = battle.questions[question_position]

        @correct_answer = answer_status

        save_battle_status

        # Finish the battle if the question position was equals of quantity of questions in battle.
        if (question_position == battle.questions.count)
            process_time(battle)
            flash[:success] = "Batalha finalizada com sucesso!"
            return render :js => "window.location.href += '/finish'"
        else
            @question = battle.questions[question_position]
        end

        @answer_letter = params[:alternative]

        return @answer_letter
        return @correct_answer
        return @question

    end

    # Name: finish.
    # Objective: this method finishes the battle.
    # Parameters: don't have parameters.
    # Return: @battle, @answers, @player_points.

    def finish

        # To seek a battle by id to finish and show player points.
        @battle = Battle.find(params[:id])
        player_answers = is_player_1?(@battle) ? @battle.player_1_answers : @battle.player_2_answers
        @answers = @battle.questions.zip(player_answers)
        player_comparison = @answers.map { |x, y| x.right_answer == y }
        player_comparison.delete(false)

        @player_points = player_comparison.count

        return @battle
        return @answers
        return @player_points

    end

    # Name: result.
    # Objective: this method shows the result of the battle.
    # Parameters: don't have parameters.
    # Return: @battle, @current_player_stats, @adversary_stats, @answers.

    def result

        # To seek a battle according to id .
        @battle = Battle.find(params[:id])

        if (@battle.processed?)
            count_questions
        else
            process_result
        end

        # Reload the battle.
        @battle.reload
        if is_player_1?(@battle)
            current_player_answers = @battle.player_1_answers
            adversary_answers = @battle.player_2_answers
            @current_player_stats = [@player_1_points, @battle.player_1_time]
            @adversary_stats = [@player_2_points, @battle.player_2_time]
        else
            current_player_answers = @battle.player_2_answers
            adversary_answers = @battle.player_1_answers
            @current_player_stats = [@player_2_points, @battle.player_2_time]
            @adversary_stats = [@player_1_points, @battle.player_1_time]
        end

        @current_player_stats[1] = @current_player_stats.second >= 610 ? "--:--" : "#{@current_player_stats.second / 60}:#{@current_player_stats.second % 60 < 10 ? "0" : ""}#{@current_player_stats.second % 60}"
        @adversary_stats[1] = @adversary_stats.second >= 610 ? "--:--" : "#{@adversary_stats.second / 60}:#{@adversary_stats.second % 60 < 10 ? "0" : ""}#{@adversary_stats.second % 60}"
        @answers = @battle.questions.zip(current_player_answers, adversary_answers)

        return @battle
        return @current_player_stats
        return @adversary_stats
        return @answers

    end

    # Name: generate_random_user.
    # Objective: this method create a random user.
    # Parameters: don't have parameters.
    # Return: render :text => random_user.nickname.

    def generate_random_user

        random_user = (User.all - [current_user]).sample

        return render :text => random_user.nickname

    end

end
