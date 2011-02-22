if !defined?(Civiccommons::Config)

  module Civiccommons
    class Config
      CC_CONFIG = YAML.load_file(File.join(Rails.root, "config", "civic_commons.yml"))

      cattr_accessor :devise_email, :devise_mailer_host, :devise_pepper, :rails_secret_token,
                     :smtp_address, :smtp_domain, :smtp_username, :smtp_password,
                     :mailer_api_token, :mailer_list,
                     :facebook_app_id, :facebook_app_secret

      @@devise_email       ||= CC_CONFIG[Rails.env]['devise_email']       if CC_CONFIG[Rails.env]['devise_email']
      @@devise_mailer_host ||= CC_CONFIG[Rails.env]['devise_mailer_host'] if CC_CONFIG[Rails.env]['devise_mailer_host']
      @@devise_pepper      ||= CC_CONFIG[Rails.env]['devise_pepper']      if CC_CONFIG[Rails.env]['devise_pepper']
      @@rails_secret_token ||= CC_CONFIG[Rails.env]['rails_secret_token'] if CC_CONFIG[Rails.env]['rails_secret_token']
      @@smtp_address       ||= CC_CONFIG[Rails.env]['smtp_address']       if CC_CONFIG[Rails.env]['smtp_address']
      @@smtp_domain        ||= CC_CONFIG[Rails.env]['smtp_domain']        if CC_CONFIG[Rails.env]['smtp_domain']
      @@smtp_username      ||= CC_CONFIG[Rails.env]['smtp_username']      if CC_CONFIG[Rails.env]['smtp_username']
      @@smtp_password      ||= CC_CONFIG[Rails.env]['smtp_password']      if CC_CONFIG[Rails.env]['smtp_password']
      @@mailer_api_token   ||= CC_CONFIG[Rails.env]['mailer_api_token']   if CC_CONFIG[Rails.env]['mailer_api_token']
      @@mailer_list        ||= CC_CONFIG[Rails.env]['mailer_list']        if CC_CONFIG[Rails.env]['mailer_list']
      @@facebook_app_id    ||= CC_CONFIG[Rails.env]['facebook_app_id']    if CC_CONFIG[Rails.env]['facebook_app_id']
      @@facebook_app_secret ||= CC_CONFIG[Rails.env]['facebook_app_secret'] if CC_CONFIG[Rails.env]['facebook_app_secret']
    end
  end

end
