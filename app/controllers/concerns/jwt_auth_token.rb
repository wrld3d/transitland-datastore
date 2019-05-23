# https://github.com/jimjeffers/rails-devise-cors-jwt-example/blob/master/lib/auth_token.rb

module JwtAuthToken
  extend ActiveSupport::Concern

  SIGNING_ALGORITHM = 'HS256'

  def self.issue_token(payload)
    payload['exp'] = 24.hours.from_now.to_i # Set expiration to 24 hours.
    JWT.encode(payload, Rails.application.secrets.secret_key_base, SIGNING_ALGORITHM)
  end

  def self.valid?(token)
    begin
      JWT.decode(token, Rails.application.secrets.secret_key_base, true, { algorithm: SIGNING_ALGORITHM })
    rescue
      false
    end
  end

  def verify_jwt_token
    # if request.headers['Authorization'].present?
    #   token = request.headers['Authorization'].split(' ').last
    #   if JwtAuthToken.valid?(token)
    #     return true
    #   end
    # end
    # return head :unauthorized
    return true
  end
end
