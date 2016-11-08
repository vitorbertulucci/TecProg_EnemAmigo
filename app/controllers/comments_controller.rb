# Class: comments_controller.rb.
# Purpose: This class is designed to control the actions of comments within the Enem Amigo.
# Enem Amigo.
# FGA - Universidade de Brasíilia UnB.

class CommentsController < ApplicationController

    # Checks for user logged in.
    before_action :authenticate_user
    before_action :verify_user_permission, only: [:destroy, :edit]

    # Name:
	# 	- new
	# Objective:
	# 	- this method create a new instance of comment on system.
	# *	*Args* :
	#  	- none.
	# * *Returns* :
	# 	- +comment+ -> comment object.

    def new

        # To instance a new comment object
        @comment = Comment.new(nil)
        assert(@comment.kind_of?(Comment), 'The object @comment it could not be instantiated')
        logger.debug('A comment object has been instantiated')

        return @comment
        logger.info('The aplication has been redirected to the page that a comment can be created')

    end

    # Name:
	# 	- create
	# Objective:
	# 	- this method create a new instance of company on system.
	# *	*Args* :
	#  	- post identifier and topic identifier..
	# * *Returns* :
	# 	- +redirect+ -> redirect to the topic page or comment page.

    def create

        # To create a new comment on topic.
        @comment = Comment.new(set_comment_params)
        assert(@comment.kind_of?(Comment), 'The object @comment it could not be instantiated'
        + 'because does not belong to controller')
        logger.debug('A comment object has been instantiated')

        # Add the attribute id of current user to create a new comment object
        @comment.user_id = current_user.id
        assert(@comment.user_id != nil, 'The attribute user_id of @comment is null')
        logger.debug('A comment user identifier receive current user identifier')

        # Add the attribute post id to create a new comment object
        @comment.post_id = params[:post_id]
        assert(@comment.post_id != nil, 'The attribute post_id of @comment is null')
        logger.debug('A comment user identifier receive current user identifier')

        # Validate the creation of the object to redirect their respective topic
        if (@comment.save)
            flash[:success] = 'Seu comentário foi criado com sucesso'
            return redirect_to(Topic.find(session[:topic_id]))
            logger.info('The aplication has been redirected to topic page')
        else
            return redirect_to(new_post_comment_path(params[:post_id]))
            logger.info('The aplication has been redirected to create comment page')
        end

    end

    # Name:
	# 	- edit
	# Objective:
	# 	- this method find the comment to be edited or deleted.
	# *	*Args* :
	#  	- none.
	# * *Returns* :
	# 	- +comment+ -> comment object

    def edit

        # To seek proper comment to be edited using your id as parameter
        @comment = Comment.find(params[:comment_id])
        assert(@comment != nil, 'The object @comment is null')
        logger.debug('A comment object has been found')

        return @comment
        logger.info('The aplication has been redirected to create comment page')

    end

    # Name:
	# 	- update
	# Objective:
	# 	- this method edit an comment in the database.
	# *	*Args* :
	#  	- comment identifier and topic identifier..
	# * *Returns* :
	# 	- +redirect+ -> redirection to Topic page or edit comment page

    def update

        # To update the review with their modifications due, taking the function to edit attributes
        @comment = Comment.find(params[:comment_id])
        assert(@comment != nil, 'The object @comment is null')
        logger.debug('A comment object has been found')

        # Validate the update of the object to redirect their respective topic
        if (@comment.update_attributes(comment_params))
          flash[:success] = "Seu comentário foi atualizado com sucesso"
          return redirect_to(Topic.find(session[:topic_id]))
          logger.info('The aplication has been redirected to topic page')
        else
          return redirect_to(edit_post_comment_path(session[:topic_id]))
          logger.info('The aplication has been redirected to edit comment page')
        end

    end

    # Name:
	# 	- rate_comment
	# Objective:
	# 	- this method rate a comment in topic page.
	# *	*Args* :
	#  	- comment identifier.
	# * *Returns* :
	# 	- none.

    def rate_comment

        render nothing: true

        # Destined to find its comment and make a request to rate.
        comment = Comment.find(params[:id])
        assert(@comment != nil, 'The object @comment is null')
        logger.debug('A comment object has been found')

        # Validate the evaluations made by the current user on the system and then save.
        if(!comment.user_ratings.include? current_user.id)
            comment.user_ratings.push(current_user.id)
            begin
                comment.save
            rescue Exception
                flash[:error] = "Não foi possível realizar o comentário. Tente novamente!"
            end
        else
            return redirect_to_back(root_path)
            logger.info('The aplication has been redirected to home page')
        end

    end

    # Name:
	# 	- destroy
	# Objective:
	# 	- this method delete an commment on database .
	# *	*Args* :
	#  	- comment identifier
	# * *Returns* :
	# 	- +redirect+ -> redirection to topic page

    def destroy

        # Destined to find its comment and make a request to delete.
        @comment = Comment.find(params[:comment_id])
        assert(@comment != nil, 'The object @comment is null')
        logger.debug('A comment object has been found')

        # To delete the comment, destroying their dependencies with topic foreign key.
        @comment.destroy
        assert(@comment == nil, 'The object @comment was not destroyed because'
        + 'isnt null')
        logger.debug('A comment object has been destroyed')

        # Show on the screen a success message in operation.
        flash[:success] = "Comentário deletado com sucesso"

        return redirect_to(Topic.find(session[:topic_id]))
        logger.info('The aplication has been redirected to the topic page')

    end

    # Name:
	# 	- show
	# Objective:
	# 	- this method renders the comment's page.
	# *	*Args* :
	#  	- comment identifier
	# * *Returns* :
	# 	- +comment+ -> comment object

    def show

        # Find the commentar for viewing.
        @comment = Comment.find(params[:id])
        assert(@comment != nil, 'The object @comment is null')
        logger.debug('A comment object has been found')

        return @comment
        logger.info('The aplication has been redirected to show comment page')

    end

    private


        def set_comment_params

            params.require(:comment).permit(:content)

        end

end
