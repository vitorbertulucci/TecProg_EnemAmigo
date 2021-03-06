# Class: posts_controller.rb.
# Purpose: This class is designed to control the actions of post within the Enem Amigo.
# Enem Amigo.
# FGA - Universidade de Brasíilia UnB.

class PostsController < ApplicationController

  before_action :authenticate_user
  before_action :verify_user_permission, only: [:destroy, :edit, :update]

  # Name: new
	# Objective: this method create a new instance post on system.
	# Parameters: don't have parameters.
	# Return: post object.

  def new

    # To instance a new post object
    @post = Post.new(nil)
    assert(@post.kind_of?(Post), 'The object @post it could not be instantiated'
    + 'because does not belong to controller')

    return @post

  end

  # Name: create
	# Objective: this method create a new post on system.
	# Parameters: don't have parameters.
	# Return: post object.

  def create

    # To create a new post on topic
    @post = Post.new(set_post_params)
    assert(@post.kind_of?(Post), 'The object @post it could not be instantiated'
    + 'because does not belong to controller')

    # Add the attribute id of current user to create a new post object
    @post.user_id = current_user.id
    assert(@post.user_id != nil, 'The attribute user_id of @post is null')

    # Add the attribute topic id to create a new post object
    @post.topic_id = session[:topic_id]
    assert(@post.topic_id != nil, 'The attribute topic_id of @post is null')

    # Validate the creation of the object to redirect their respective topic
    if(@post.save)
      flash[:success] = "Postagem criada com sucesso"
      return redirect_to Topic.find(session[:topic_id])
    else
      return render('new')
    end

  end

  # Name: show
	# Objective: this method render the post's page.
	# Parameters: post identifier.
	# Return: post object.

  def show

    # Find the post for viewing
    @post = Post.find(params[:id])
    assert(@post != nil, 'The object @post is null')

    return @post

  end

  # Name: index
	# Objective: this method give all posts to user.
	# Parameters: array post.
	# Return: array post.

  def index

    # Search all posts of current user
    @posts = Post.all
    assert(@posts != nil, 'The array @posts is null')

    return @posts

  end

  # Name: edit
	# Objective: this method find the post to be edited or deleted.
	# Parameters: don't have parameters.
	# Return: post object.

  def edit

    # To seek proper post to be edited using your id as parameter
    @post = Post.find(params[:post_id])
    assert(@post != nil, 'The object @post is null')

    return @post

  end

  # Name: update
	# Objective: this method edit an post in the database.
	# Parameters: post identifier.
	# Return: render topic post page or edit post page.

  def update

    # To update the review with their modifications due, taking the function to edit attributes
    @post = Post.find(params[:post_id])
    assert(@post != nil, 'The object @post is null')

    # Validate the update of the object to redirect their respective topic
    if(@post.update_attributes(set_post_params))
      flash[:success] = "Seu post foi atualizado com sucesso"
      redirect_to Topic.find(session[:topic_id])
    else
      return render('edit')
    end

  end

  # Name: user_name
	# Objective: this method find the user owner of post.
	# Parameters: user identifier.
	# Return: user object.

  def user_name(user_id)

    # Seek user by your name to display on the screen
    user = User.where(id: user_id).name
    assert(user.kind_of(User), 'User object is not valid')

  end

  # Name:rate_post
	# Objective: this method rate a post in topic page.
	# Parameters: post identifier
	# Return: saved post.

  def rate_post

    render nothing: true

    # Destined to find its post and make a request to rate
    post = Post.find(params[:id])
    assert(@post != nil, 'The object @post is null')

    # Validate the rates made by the current user on the system and then save
    if(!post.user_ratings.include? current_user.id)
      post.user_ratings.push(current_user.id)
      post.save
    else
      return redirect_to_back(root_path)
    end

  end

  # Name: destroy
	# Objective: this method destroy a post register.
	# Parameters: post identifier.
	# Return: topic page.

  def destroy

    # Destined to find its post and make a request to delete
    @post = Post.find(params[:post_id])
    assert(@post != nil, 'The object @post is null')

    # To delete the post, destroying their dependencies with topic foreign key
    @post.destroy
    assert(@post == nil, 'The object @post isnt null')

    # Show on the screen a success message in operation
    flash[:success] = "Post deletado com sucesso"

    return redirect_to(Topic.find(session[:topic_id]))

  end

  # Name: set_post_params
	# Objective: this method leads the post's parameters for the methods.
	# Parameters: post object.
	# Return: don't have return.

  private

  def set_post_params

    params.require(:post).permit(:content)

  end

end
