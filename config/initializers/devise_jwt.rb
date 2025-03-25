# Set the expiration time for JWT tokens
Devise.setup do |config|
  config.jwt do |jwt|
    # Default expiration time is 3 hours
    jwt.expiration_time = 3.hours.to_i

    # If you want different expiration times for different environments, use:
    jwt.expiration_time = Rails.env.test? ? 1.day.to_i : 3.hours.to_i
  end
end
