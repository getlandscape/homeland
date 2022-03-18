# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :require_no_sso!, only: %i[new create]

  def create
    wallet_type = params[:wallet_type]
    if wallet_type.present? && wallet_type.in?(User::SUPPORTED_WALLET_TYPES)
      address_column = "#{wallet_type}_address"
      user = User.where("#{address_column} = ?", params[:address]).first
      Rails.logger.info "== user login with #{wallet_type}, user: #{user.inspect}"
      if user.present?
        sign_in user
        redirect_back_or_default(root_url)
      else
        redirect_to new_user_session_path, alert: "Sign in failed."
      end
    else
      resource = warden.authenticate!(auth_options)
      set_flash_message(:notice, :signed_in) if is_navigational_format?

      if session[:omniauth]
        @auth = Authorization.find_or_create_by!(provider: session[:omniauth]["provider"], uid: session[:omniauth]["uid"], user_id: resource.id)
        if @auth.blank?
          redirect_to new_user_session_path, alert: "Sign in failed."
          return
        end

        set_flash_message(:notice, "Sign in successfully with bind #{Homeland::Utils.omniauth_name(session[:omniauth]["provider"])}")
        session[:omniauth] = nil
      end

      sign_in(resource_name, resource)
      yield resource if block_given?
      respond_to do |format|
        format.html { redirect_back_or_default(root_url) }
        format.json { render status: "201", json: resource.as_json(only: %i[login email]) }
      end
    end
  end
end
