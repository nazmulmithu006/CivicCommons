class Registrations::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  def facebook
    if signed_in? && !current_person.facebook_authenticated?
      authentication = Authentication.new_from_auth_hash(env['omniauth.auth'])
      if current_person.link_with_facebook(authentication)
        flash[:notice] = I18n.t "devise.omniauth_callbacks.linked_success", :kind => "Facebook"
      else
        flash[:notice] = I18n.t "devise.omniauth_callbacks.linked_failure", :kind => "Facebook"
      end
    end
    redirect_to root_path
  end
  
end