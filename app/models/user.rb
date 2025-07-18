class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable, :lockable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  # Build/return a user for Google OAuth2
  def self.from_google(uid:, email:, full_name:)
    first, *rest = full_name.to_s.split(" ")
    last = rest.join(" ").presence

    user = find_or_initialize_by(email: email)

    # Always keep provider/uid in sync
    user.provider = "google_oauth2"
    user.uid = uid

    # Only set these the first time (or if blank)
    user.password = Devise.friendly_token[0, 20] if user.encrypted_password.blank?
    user.first_name ||= first
    user.last_name  ||= last

    # Basic username strategy: email local part; ensure uniqueness if needed
    user.username ||= generate_username_from_email(email)

    # Auto-confirm users coming from Google
    user.confirmed_at ||= Time.current

    user.save!  # will raise if invalid; see rescue pattern below if you prefer

    user
  end

  # Simple helper; expand if you need uniqueness enforcement
  def self.generate_username_from_email(email)
    email.split("@").first.parameterize.underscore
  end
end
