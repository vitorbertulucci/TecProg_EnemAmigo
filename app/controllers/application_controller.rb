# Class: application_controller.rb.
# Purpose: This class is designed to control the actions of the application in Enem Amigo.
# Enem Amigo.
# FGA - Universidade de Brasíilia UnB.

class ApplicationController < ActionController::Base

    protect_from_forgery with: :exception

    include SessionsHelper
    include MedalsHelper
    include NotificationsHelper
    include UsersHelper

    if (ENV['RAILS_ENV'] == 'production')
        rescue_from Exception, :with => :server_exception
        rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found
        rescue_from ActionController::RoutingError, :with => :raise_not_found!

        # Name: server_exception
        # Objective: this method shows an error message of servidor.
        # Parameters: don't have parameters.
        # Return: redirect_to server_error_path.

        def server_exception

            flash.now[:danger] = "Ocorreu um erro no servidor"
            session[:exception] = "exception"

            return redirect_to server_error_path

        end

        # Name: raise_not_found!
        # Objective: this method shows an error message of page not found.
        # Parameters: don't have parameters.
        # Return: redirect_to_back(root_path).

        def raise_not_found!

            flash[:danger] = "Página não encontrada"

            return redirect_to_back(root_path)

        end

        # Name: record_not_found
        # Objective: this method shows an error message of question or user not found.
        # Parameters: don't have parameters.
        # Return: redirect_to_back(root_path).

        def record_not_found

            resource = request.url[/(\/\w+\/)/, 0]
            resource.slice!(0)
            resource.slice!(resource.length - 1)

            flash[:danger] = "#{resource.singularize == 'question' ? 'Questão não encontrada' : 'Usuário não encontrado'}"

            return redirect_to_back(root_path)

        end

    end

end
