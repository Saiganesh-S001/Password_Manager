module V1
  class Base < Grape::API
    mount V1::Auth
    mount V1::PasswordRecords
    mount V1::SharedPasswordRecords

    add_swagger_documentation(
      api_version: "v1",
      hide_documentation_path: true,
      mount_path: "/swagger_doc",
      hide_format: true,
      info: {
        title: "Password Manager API",
        description: "API for the Password Manager app"
      }
    )
  end
end
