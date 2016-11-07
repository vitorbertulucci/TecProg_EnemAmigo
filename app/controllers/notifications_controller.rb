# Class: posts_controller.rb.
# Purpose: This class is designed to control the actions of post within the Enem Amigo.
# Enem Amigo.
# FGA - Universidade de Brasíilia UnB.

class NotificationsController < ApplicationController

  # Name: new
	# Objective: this method create a new instance post on system.
	# Parameters: don't have parameters.
	# Return: post object.

  def index

    @notifications = current_user.notifications.reverse

  end

  # Name: new
	# Objective: this method create a new instance post on system.
	# Parameters: don't have parameters.
	# Return: post object.

  def read

    render :nothing => true
    @notifications = current_user.notifications.where(visualized: false)

    @notifications.each do |notification|
      notification.update_attribute(:visualized, true)
    end

  end

end
