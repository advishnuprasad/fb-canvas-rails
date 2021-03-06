class ApplicationController < ActionController::Base
  before_filter :detect_facebook_post!
  protect_from_forgery
  layout :set_layout

  helper_method :get_session
  helper_method :logged_in?, :current_user

  #
  # Detect if we're received a POST with a signed_request parameter.
  #
  # The request has already been turned into a GET request at this point to
  # preserve RESTfulness, but we can access the signed_request and it's
  # deencrypted version through request.env['facebook.signed_request']
  # and request.env['facebook.params'].
  #
  def detect_facebook_post!
    logger.info "Am getting called"
    logger.info request.env['facebook.params']
    if request.env['facebook.params']
      logger.info "Received POST w/ signed_request from Facebook."
      log_in_with_facebook request.env['facebook.params']
    end
    true
  end

  def redirect_to_auth_facebook!
    redirect_to '/auth/facebook'
  end

  def log_in_with_facebook(auth_hash)
    logger.info auth_hash
    if auth_hash['uid'] || auth_hash['user_id']
      logger.info "Logging in with Facebook..."
      if current_user.nil?
        logger.info "Logging in user #{auth_hash['uid'] || auth_hash['user_id']}"

        # In real life, you'd perform some real authentication here
        # user = User.from_omniauth(auth_hash)
        # u = {}
        # u[:uid]              = (auth_hash['uid'] || auth_hash['user_id']).to_i
        # u[:token]            = auth_hash.value_at_path 'credentials', 'token'
        # u[:token_expires_at] = Time.at(auth_hash.value_at_path('credentials', 'expires_at').to_i)
        # u[:logged_in_at]     = Time.now
        user = User.where(provider: 'facebook', email: auth_hash['user_id']).first_or_create do |user|
          user.encrypted_password = "password"
          user.last_sign_in_at = Time.now
        end
        session[:user_id] = user.id
      end
      true
    else
      logger.info "Tried to login with Facebook. :uid was not specified. Aborting."
      log_out
      false
    end
  end

  def current_user
    @current_user ||= begin
      if session[:user_id]
        User.find(session[:user_id])
      else
        nil
      end
    end
    @current_user
  end

  def logged_in?
    !! get_session[:user_id]
  end

  def log_out
    session[:user_id] = nil
  end

  # Get the session. If it's present in the header, this has precedence over the regular cookie session.
  def get_session
    if has_session_in_header?
      logger.info "Reading session from header"
      return @header_session if @header_session
      encrypted_session = request.headers['X-Session']
      secret = FBCanvasRails::Application.config.secret_token
      verifier = ActiveSupport::MessageVerifier.new(secret, 'SHA1')
      @header_session = verifier.verify(encrypted_session).with_indifferent_access
    else
      logger.info "Reading session from cookies"
      session
    end
  end

private
    # Change layout if request was CJAX
    def set_layout
      if request.headers['X-CJAX']
        logger.info "CJAX request received."
        "cjax"
      else
        logger.info "Regular, non-CJAX request received."
        "application"
      end
    end

  # Session present in request header (for CJAX requests)
  def has_session_in_header?
    !!(request.headers['X-Session'])
  end
end
