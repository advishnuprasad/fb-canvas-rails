class SessionController < ApplicationController
  skip_before_filter :detect_facebook_post!
  skip_before_filter :verify_authenticity_token

  def create
    logger.info request.env['omniauth.auth']
    if request.env['omniauth.auth']
      user = User.from_omniauth(request.env['omniauth.auth'])
      session[:user_id] = user.id
      redirect_to '/'
    else
      logger.info "Failed to create a session"
      logger.info request.env['omniauth.auth'].to_yaml
      log_out
      redirect_to '/'
    end
  end

  def destroy
    log_out
    redirect_to_auth_facebook!
  end

end