class User < ActiveRecord::Base
  def self.from_omniauth(auth)
    p auth
    where(provider: auth.provider, email: auth.info.email_id).first_or_create do |user|
      user.email = auth.info.email
      user.encrypted_password = "password"
      user.last_sign_in_at = Time.now
    end
  end
end
