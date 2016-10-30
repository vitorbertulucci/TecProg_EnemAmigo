# Class: users_controller.rb.
# Purpose: This class is designed to control the actions of users
# Enem Amigo.
# FGA - Universidade de Brasíilia UnB.

class UsersController < ApplicationController

    before_action :authenticate_user, except: [:ranking, :new, :create]
    before_action :verify_user_permission, only: [:edit, :destroy]

    # Name:
	# 	- new
	# Objective:
	# 	- create an user object
	# *	*Args* :
	#  	- none.
	# * *Returns* :
	# 	- +home_page+ -> redirect to the home page.
	# 	- +user+ -> user object.

    def new

        @home_page = true
        assert(@home_page, 'Home page is not valid.')
        logger.debug('A boolean constant was created to the page be redirected to home page')

        @user = User.new
        assert(@user.kind_of(User), 'User object is not valid')
        logger.debug('A user object has been created')

        if (logged_in?)
            return redirect_to current_user
            logger.info('The aplication has been redirected to current user profile')
        else
            return @user
            logger.info('The aplication has been redirected to the page that creating a new user')
        end

    end

    # Name:
	# 	- edit
	# Objective:
	# 	- find an user to edit its attributes
	# *	*Args* :
	#  	- user identifier
	# * *Returns* :
	# 	- +user+ -> user object.

    def edit

        @user = User.find(params[:id])
        assert(@user != nil, 'Do not have any User with this identifier')
        logger.debug('A user object has been created')

        return @user
        logger.info('The aplication has been redirected to the page that user can edit his own profile')

    end

    # Name:
	# 	- destroy
	# Objective:
	# 	- destroy a user register
	# *	*Args* :
	#  	- user identifier
	# * *Returns* :
	# 	- +users_path+ -> redirection to login page

    def destroy

        @user = User.find(params[:id])
        assert(@user != nil, 'Do not have any User with this identifier')
        logger.debug('A user object has been found')

        @user.destroy
        assert(@user == nil, 'User doesn\'t have been destroyed.')
        logger.debug('A user object has been destroyed')


        flash[:success] = "Usuário foi deletado"
        return redirect_to users_path
        logger.info('The aplication has been redirected to the page login page')

    end

    # Name:
	# 	- show
	# Objective:
	# 	- show levels of current user
	# *	*Args* :
	#  	- user identifier
	# * *Returns* :
	# 	- +user+ -> user object
	# 	- +points+ -> redirection to login page

    def show

        @user = User.find(params[:id])
        assert(@user != nil, 'Do not have any User with this identifier')
        logger.debug('A user object has been found to be showed')

        return find_level current_user.points
        logger.info('The aplication has been redirected to the page that levels of user is showed')

    end

    # Name:
	# 	- create
	# Objective:
	# 	- create a user
	# *	*Args* :
	#  	- user attributes
	# * *Returns* :
	# 	- +root_path+ -> redirection tto home page
	# 	- +render 'new'+ -> redirection to create user page

    def create

        @user = User.new(set_user_attributes)
        assert(@user != nil, 'Couldn\'t create a user with this attibutes')
        logger.debug('A user object has been created')

        if(@user.save)
            flash[:success] = "Usuário criado com sucesso!"
            log_in @user
            assert(@user == current_user, 'Failed on loggin user.')
            logger.info('The created user was logged in')

            first_notification
            return redirect_to root_path
            logger.info('The appication has been redirected to menu page')
        else
            @home_page = true
            assert(@home_page, 'Home page is not valid.')
            logger.debug('A boolean constant was created to the page be redirected to home page')

            return render 'new'
            logger.info('The appication has been redirected create user page')
        end

    end

    # Name:
	# 	- update
	# Objective:
	# 	- update user attributes
	# *	*Args* :
	#  	- user identifier and its attributes
	# * *Returns* :
	# 	- +user+ -> user object

    def update

        @user = User.find(params[:id])
        assert(@user != nil, 'Do not have any User with this identifier')
        logger.debug('A user object has been found to be updated')

        if(@user.update_attributes(set_user_attributes))
            flash[:success]= "Usuário atualizado"
            return redirect_to @user
            logger.info('The appication has been redirected create user page')
        else
            return render 'edit'
            logger.info('The appication has been redirected to edit user page')
        end

    end

    # Name:
	# 	- index
	# Objective:
	# 	- get all users registered in system
	# *	*Args* :
	#  	- none
	# * *Returns* :
	# 	- +users+ -> array of users objects

    def index

        @users = User.all
        assert(@users != nil, 'Can\'t find any user')
        logger.debug('A users object array has been created')

        return @users
        logger.info('The application has been redirected to show all users page')

    end

    # Name:
	# 	- ranking
	# Objective:
	# 	- get all users ordered by points
	# *	*Args* :
	#  	- none
	# * *Returns* :
	# 	- +users+ -> ordered users array

    def ranking

        if(logged_in?)
            @users = User.order(:points).reverse # ordered users for the highest points to minor points
            assert(@user != nil, 'Couldn\'t find any users.')
            logger.debug('A users array has been created')

            return @users
            logger.info('The application has been redirected users ranking page')

        else
            @home_page = true
            assert(@home_page, 'Home page is not valid.')
            logger.debug('A boolean constant was created to the page be redirected to home page')

            return @home_page
            logger.info('The application has been redirected to home page')
        end

    end

    # Name:
	# 	- delete_profile_image
	# Objective:
	# 	- delete a profile image from a user profile
	# *	*Args* :
	#  	- none
	# * *Returns* :
	# 	- +user_path+ -> user profile page

    def delete_profile_image

        if(!current_user.profile_image_file_name.empty?)
            current_user.update_attribute(:profile_image_file_name,"")
            flash[:success] = "Foto de perfil removida com sucesso!"
            logger.info('A current user profile image has been deleted')
        else
            flash[:danger] = "Não há foto de perfil para ser removida."
        end
        return redirect_to user_path(current_user.id)
        logger.info('The application has been redirected to current user page')

    end

    private

        def set_user_attributes

            params.require(:user).permit(:name, :email, :level, :points, :nickname,
                                       :password_digest,:password, :password_confirmation, :profile_image)

        end

end
