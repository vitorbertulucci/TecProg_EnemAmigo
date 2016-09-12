# Class: topics_controller.rb.
# Purpose: This class is designed to control the actions of topics.
# Enem Amigo.
# FGA - Universidade de Brasíilia UnB.

class TopicsController < ApplicationController

	include PostsHelper

	before_action :authenticate_user
	before_action :verify_user_permission, only: [:edit, :destroy]
  	before_action :authenticate_admin, only: [ :new, :create, :edit, :destroy, :update ]

	# Name: new
    # Objective: create an topic object.
    # Parameters: none.
    # Return: topic object.

	def new

		@topic = Topic.new(nil)

		return @topic

	end

	# Name: create
	# Objective: create an topic object.
	# Parameters: name and description.
	# Return: topic object.

	def create

		@topic = Topic.new(set_topic_attributes)

		if(@topic.save)
			flash[:success] = "Tópico criado com sucesso"
			return redirect_to @topic
		else
			#nothing to do
		end

	end

	# Name: show
    # Objective: find a topic to be showed.
    # Parameters: topic identifier.
    # Return: topic object.

	def show

		@topic = Topic.find(params[:id])
		session[:topic_id] = @topic.id

		return @topic

	end

	# Name: index
    # Objective: show all topics in home page.
	# Parameters: none.
    # Return: topic array.

	def index

		@topics = Topic.all

		return @topics

	end

	private

		def set_topic_attributes

			params.require(:topic).permit(:name, :description)

		end

end
