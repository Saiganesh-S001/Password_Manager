module Root
  class Base < Grape::API
    prefix "api"    # Base path for all API routes: /api
    format :json    # Response format

    # Mount API versions
    mount Root::V1::Base

    # Root endpoint (optional)
    get do
      { message: "Welcome to the API" }
    end

    resource :check do
      get :health do
        { message: "Verification successful" }
      end
    end
  end
end
