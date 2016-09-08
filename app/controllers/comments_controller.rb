# Class: comments_controller.rb.
# Purpose: This class manages the page comments.
# Enem Amigo.
# FGA - Universidade de Brasíilia UnB.

class CommentsController < ApplicationController

  # Checks for user logged in.
  before_action :authenticate_user
  before_action :verify_user_permission, only: [:destroy, :edit]

  # Name: new.
	# Objective: this method set a new comment.
	# Parameters: don't have parameters.
	# Return: nothing.

  def new
    @comment = Comment.new
  end

  # Name: create.
	# Objective: this method create a new comment on page.
	# Parameters: post identifier and topic identifier.
	# Return: redirect the user to the page topic.

  def create
    @comment = Comment.new(comment_params)
    @comment.user_id = current_user.id
    @comment.post_id = params[:post_id]
    if (@comment.save)
      flash[:success] = "Seu comentário foi criado com sucesso"
      return redirect_to Topic.find(session[:topic_id])
    else
      return redirect_to new_post_comment_path(params[:post_id])
    end
  end

  # Name: edit.
	# Objective: this method find the comment to be edited or deleted.
	# Parameters: don't have parameters.
	# Return: nothing.

  def edit
    @comment = Comment.find(params[:comment_id])
  end

  # Name: update.
	# Objective: update comments made by users.
	# Parameters: comment identifier and topic identifier.
	# Return: redirect the user to the page topic.

  def update
    @comment = Comment.find(params[:comment_id])
    if (@comment.update_attributes(comment_params))
      flash[:success] = "Seu comentário foi atualizado com sucesso"
      return redirect_to Topic.find(session[:topic_id])
    else
      return redirect_to edit_post_comment_path(session[:topic_id])
    end
  end

  # Name: rate_comment.
	# Objective:
	# Parameters:
	# Return: nothing.

  def rate_comment
    render nothing: true
    comment = Comment.find(params[:id])

    if (not comment.user_ratings.include? current_user.id)
      comment.user_ratings.push(current_user.id)
      comment.save
    else
      return redirect_to_back(root_path)
    end
  end

  # Name: destroy.
	# Objective: this method deletes the selected comment.
	# Parameters: comment identifier.
	# Return: redirect the user to topic page.

  def destroy
    @comment = Comment.find(params[:comment_id])
    @comment.destroy
    flash[:success] = "Comentário deletado com sucesso"
    return redirect_to Topic.find(session[:topic_id])
  end

  # Name: show.
	# Objective:
	# Parameters: comment identifier.
	# Return: nothing.

  def show
    @comment = Comment.find(params[:id])
  end

  private

  # Name: comment_params.
	# Objective:
	# Parameters: dont't have parameters.
	# Return: nothing.

  def comment_params
    params.require(:comment).permit(:content)
  end

end
