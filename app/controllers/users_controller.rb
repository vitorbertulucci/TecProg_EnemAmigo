# Class: users_controller.rb.
# Purpose: This class is designed to control the actions of users
# Enem Amigo.
# FGA - Universidade de Brasíilia UnB.

class UsersController < ApplicationController

    before_action :authenticate_user, except: [:ranking, :new, :create]
    before_action :verify_user_permission, only: [:edit, :destroy]

    # Name: new
    # Objective: create an user object
    # Parameters: none
    # Return: user object

    def new

        @home_page = true
        @user = User.new
        if (logged_in?)
            return redirect_to current_user
        else
            return @user
        end

    end

    # Name: edit
    # Objective: find an user to edit its attributes
    # Parameters: user identifier
    # Return: user object

    def edit

        @user = User.find(params[:id])
        return @user

    end

    # Name: destroy
    # Objective: destroy a user register
    # Parameters: user identifier
    # Return: redirect to login page

    def destroy

        @user = User.find(params[:id])
        @user.destroy
        flash[:success] = "Usuário foi deletado"
        return redirect_to users_path

    end

    # Name: show
    # Objective: find a user to show its profile
    # Parameters: user identifier
    # Return: user object

    def show

        @user = User.find(params[:id])
        return find_level current_user.points

    end

    # Name: create
    # Objective: create a user
    # Parameters: user attributes
    # Return: redirection to menu page

    def create

        @user = User.new(set_user_attributes)
        if(@user.save)
            flash[:success] = "Usuário criado com sucesso!"
            log_in @user
            first_notification
            return redirect_to root_path
        else
            @home_page = true
            return render 'new'
        end

    end

    # Name: update
    # Objective: update user attributes
    # Parameters: user identifier and its attributes
    # Return: user object

    def update

        @user = User.find(params[:id])
        if(@user.update_attributes(set_user_attributes))
            flash[:success]= "Usuário atualizado"
            return redirect_to @user
        else
            return render 'edit'
        end

    end

    # Name: index
    # Objective: get all users registered in system
    # Parameters: none
    # Return: user array

    def index

        @users = User.all
        return @users

    end

    # Name: ranking
    # Objective: get all users ordered by points
    # Parameters: none
    # Return: ordered user array

    def ranking

        if(logged_in?)
            @users = User.order(:points).reverse
            return @users
        else
            @home_page = true
            return @home_page
        end

    end

    # Name: delete_profile_image
    # Objective: delete a profile image from a user profile
    # Parameters: none
    # Return: user profile page

    def delete_profile_image

        if(!current_user.profile_image_file_name.empty?)
            current_user.update_attribute(:profile_image_file_name,"")
            flash[:success] = "Foto de perfil removida com sucesso!"
        else
            flash[:danger] = "Não há foto de perfil para ser removida."
        end
        return redirect_to user_path(current_user.id)

    end

    private

        # Name: set_user_attributes
        # Objective: set user attributes in a user object
        # Parameters: user object, name, email, leve, points and nickname
        # Return: none

        def set_user_attributes

            params.require(:user).permit(:name, :email, :level, :points, :nickname,
                                       :password_digest,:password, :password_confirmation, :profile_image)

        end

end
