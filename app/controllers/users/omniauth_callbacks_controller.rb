class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_google(
  uid: auth.uid,
  email: auth.info.email,
  full_name: auth.info.name
)


    if @user.persisted?
      sign_out_all_scopes
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'Google') if is_navigational_format?
    else
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  private

  def auth
    @auth ||= request.env['omniauth.auth']
  end
end
