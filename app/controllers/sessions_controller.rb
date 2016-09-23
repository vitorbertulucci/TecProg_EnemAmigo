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

    @home_page = true
    assert(@home_page, 'Home page is not valid.')

    return @home_page

  end

  # Name: create
	# Objective: this method create a new session on system.
	# Parameters: email object.
	# Return: render a new page of logged user.

  def create

    user = User.find_by(email: params[:session][:email].downcase)
    assert(@user != nil, 'Do not have any User with this email')

    if(user && user.authenticate(params[:session][:password]))
      log_in(user)
      assert(user != nil, 'The user object is null')
      redirect_to(root_path)
      flash[:success] = "Logado com sucesso!"
    else
      flash.now[:danger] = 'Combinação inválida de e-mail/senha'
      render('new')
    end

  end

  # Name: destroy
	# Objective: this method destroy a session instance.
	# Parameters: user identifier.
	# Return: redirect to login page.

  def destroy

    if(current_user)
      log_out
    else
      #nothing to do
    end

    return redirect_to(login_path)

  end

end
