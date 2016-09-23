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

    assert(@missing_medals >= 0, 'Invalid value for missing medals')
    assert(@medals != nil, 'Medals array can not be null')

    return @missing_medals
    return @medals

  end

end
