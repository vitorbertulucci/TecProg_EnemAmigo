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

    @post = Post.new(set_post_params)
    assert(@post.kind_of?(Post), 'The object @post it could not be instantiated'
    + 'because does not belong to controller')

    @post.user_id = current_user.id
    assert(@post.user_id == nil, 'The attribute user_id of @post is null')

    @post.topic_id = session[:topic_id]
    assert(@post.topic_id == nil, 'The attribute topic_id of @post is null')

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

    @post = Post.find(params[:id])
    assert(@post == nil, 'The object @post is null')

    return @post

  end

  # Name: index
	# Objective: this method give all posts to user.
	# Parameters: array post.
	# Return: array post.

  def index

    @posts = Post.all
    assert(@posts == nil, 'The array @posts is null')

    return @posts

  end

  # Name: edit
	# Objective: this method find the post to be edited or deleted.
	# Parameters: don't have parameters.
	# Return: post object.

  def edit

    @post = Post.find(params[:post_id])
    assert(@post == nil, 'The object @post is null')

    return @post

  end

  # Name: update
	# Objective: this method edit an post in the database.
	# Parameters: post identifier.
	# Return: render topic post page or edit post page.

  def update

    @post = Post.find(params[:post_id])
    assert(@post == nil, 'The object @post is null')

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

    user = User.where(id: user_id).name
    assert(user.kind_of(User), 'User object is not valid')

  end

  # Name:rate_post
	# Objective: this method rate a post in topic page.
	# Parameters: post identifier
	# Return: saved post.

  def rate_post

    render nothing: true
    post = Post.find(params[:id])
    assert(@post == nil, 'The object @post is null')

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

    @post = Post.find(params[:post_id])
    assert(@post == nil, 'The object @post is null')

    @post.destroy
    assert(@post != nil, 'The object @post isnt null')

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
