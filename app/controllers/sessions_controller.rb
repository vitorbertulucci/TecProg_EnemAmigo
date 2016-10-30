# Class: sessions_controller.rb.
# Purpose: This class is designed to control the actions of session within the Enem Amigo.
# Enem Amigo.
# FGA - Universidade de Brasíilia UnB.

class SessionsController < ApplicationController

  # Name: new
  # Objective: this method create a new instance of session on system.
  # Parameters: don't have parameters.
  # Return: boolean to render home page.

  def new

    @start_session = true # Permission to create and initiate a new session on system.
    logger.debug('A new session has been instantiated')
    assert(@start_session, 'Home page is not valid.')

    return @start_session
    logger.debug('The permission of session has been passed')

  end

  # Name: create
	# Objective: this method create a new session on system.
	# Parameters: email object.
	# Return: render a new page of logged user.

  def create

    user = User.find_by(email: params[:session][:email].downcase)
    logger.debug('Finding the user by username / email')
    assert(@user != nil, 'Do not have any User with this email')

    # Checking if the password is right to log the user in the system
    if(user && user.authenticate(params[:session][:password]))
      log_in(user)
      logger.debug('User logged in system')
      assert(user != nil, 'The user object is null')
      redirect_to(root_path) # Redirects the user to the home page.
      flash[:success] = 'Logado com sucesso!'
    else
      flash.now[:danger] = 'Combinação inválida de e-mail/senha'
      render('new') # Redirects the user to the login page.
      logger.info('Application redirect to session page')
    end

  end

  # Name: destroy
	# Objective: this method destroy a session instance.
	# Parameters: user identifier.
	# Return: redirect to login page.

  def destroy

    if(current_user)
      log_out
      logger.debug('User logged out system')
    else
      #nothing to do
    end

    return redirect_to(login_path)
    logger.info('Application redirect to session log out page')

  end

end
