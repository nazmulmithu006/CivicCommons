class ApplicationController < ActionController::Base
  include ApplicationHelper
  include SecureUrlHelper
  include RedirectHelper
  include MetaHelper

  protect_from_forgery
  include AvatarHelper

  layout 'application'

  before_filter :require_no_ssl
  helper_method :with_format

protected
  def verify_admin

    if require_user and not current_person.admin?
      flash[:error] = "You must be an admin to view this page."
      redirect_to secure_session_url(current_person)
    end

  end

  def render_widget(results)
    @remote_url = params[:remote_url]
    WidgetLog.create(:url => request.path, :remote_url => @remote_url)
    if results[:css].present?
      results[:css] << '/stylesheets/widget.css'
    else
      results[:css] = ['/stylesheets/widget.css']
    end
    json = results.to_json
    callback = params[:callback]
    jsonp = callback.to_s + "(" + json + ")" #REQUIRED
    render :text => jsonp,  :content_type => "text/javascript"
  end

  def require_user
    if current_person.nil?
      # AJAX file uploads submitted normal-style via iframe, so also
      # check for custom remotipart_submitted param set in jquery.remotipart.js
      if request.xhr? || params[:remotipart_submitted]
        @requested_url = request.url
        respond_to do |format|
          format.html { render :partial => 'sessions/new_in_modal' }
          format.js { render 'sessions/new_in_modal' }
        end
      else
        redirect_to secure_new_person_session_url
      end
      return false
    else
      return true
    end
  end

  # This by default redirects everything https to http
  # need to pass in :except whenever there is a 'require_ssl' before filter
  def require_no_ssl
    if request.ssl? && SecureUrlHelper.https?
      redirect_to request.url.gsub(/^https:\/\//i, 'http://')
      return false
    end
  end

  def require_ssl
    if not request.ssl? and SecureUrlHelper.https?
      redirect_to request.url.gsub(/^http:\/\//i, 'https://')
    end
  end

  def after_sign_in_path_for(resource_or_scope)
    if RedirectHelper.valid?(session[:previous])
      session[:previous]
    elsif session[:link]
      new_link_path
    else
      root_url
    end
  end

  def with_format(format, &block)
    old_formats = formats
    self.formats = [format]
    block.call
    self.formats = old_formats
    nil
  end

end
