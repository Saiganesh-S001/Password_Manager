class API < Grape::API
  prefix "api"
  version "v1", using: :path # using path - means that the version is part of the path
  format :json

  rescue_from :all do |e|
    error!({ message: e.message }, 500) # reports the error to the client
  end

mount V1::Base
end
