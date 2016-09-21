# Class: medals_controller.rb.
# Purpose: This class is designed to control the medals Class
# Enem Amigo.
# FGA - Universidade de Brasíilia UnB.

class MedalsController < ApplicationController

  before_action :authenticate_user

  # Name: index
  # Objective: show all medals that the current have and all that it doesn't have
  # Parameters: all medals
  # Return: a missing medals object

  def index

    check_medals
    @missing_medals = @medals - current_user.medals

    return @missing_medals
    return @medals

  end

end
