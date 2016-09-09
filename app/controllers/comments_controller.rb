# Class: comments_controller.rb.
# Purpose: This class is designed to control the actions of comments within the Enem Amigo.
# Enem Amigo.
# FGA - Universidade de Brasíilia UnB.

class CommentsController < ApplicationController

  # Checks for user logged in.
  before_action :authenticate_user
  before_action :verify_user_permission, only: [:destroy, :edit]

  # Name: new
	# Objective: this method create a new instance of comment on system.
	# Parameters: don't have parameters.
	# Return: comment object.

  def new

    @comment = Comment.new(nil)

    return @comment

  end

  # Name: create
	# Objective: this method create a new instance of company on system.
	# Parameters: post identifier and topic identifier..
	# Return: redirect to the topic page or comment page.

  def create

    @comment = Comment.new(set_comment_params)
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
	# Return: comment object.

  def edit

    @comment = Comment.find(params[:comment_id])

    return @comment

  end

  # Name: update.
  # Objective: this class edit an comment in the database.
	# Parameters: comment identifier and topic identifier.
	# Return: redirect to topic page or edited post.

  def update
    @comment = Comment.find(params[:comment_id])

    if (@comment.update_attributes(comment_params))
      flash[:success] = "Seu comentário foi atualizado com sucesso"
      return redirect_to Topic.find(session[:topic_id])
    else
      return redirect_to edit_post_comment_path(session[:topic_id])
    end

  end

  # Name: rate_comment
	# Objective: this method rate a comment in topic page.
	# Parameters: comment identifier.
	# Return: save comment.

  def rate_comment
    render nothing: true
    comment = Comment.find(params[:id])

    if(!comment.user_ratings.include? current_user.id)
      comment.user_ratings.push(current_user.id)
      comment.save
    else
      return redirect_to_back(root_path)
    end

  end

  # Name: destroy
	# Objective: this method delet an commment on database .
	# Parameters: comment identifier.
	# Return: redirect the user to topic page.

  def destroy

    @comment = Comment.find(params[:comment_id])
    @comment.destroy
    flash[:success] = "Comentário deletado com sucesso"

    return redirect_to Topic.find(session[:topic_id])

  end

  # Name: show.
	# Objective: this method renders the comment's page.
	# Parameters: comment identifier.
	# Return: comment object.

  def show

    @comment = Comment.find(params[:id])

    return @comment

  end

  private

  # Name: set_comment_params
	# Objective: this method leads the comment's parameters for the methods.
	# Parameters: company object.
	# Return: don't have return.

  def set_comment_params
    params.require(:comment).permit(:content)
  end

end
