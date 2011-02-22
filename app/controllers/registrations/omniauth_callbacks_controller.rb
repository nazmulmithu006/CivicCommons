class Registrations::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def facebook
    render :text => "facebook #{env["omniauth.auth"].inspect.to_s}"
  end
end