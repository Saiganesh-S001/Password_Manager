# Disable Zeitwerk for our API paths
Rails.autoloaders.main.ignore(Rails.root.join("app/api"))

# Manual loading for our API files in the correct order
Rails.application.config.to_prepare do
  # First load module definitions
  # load Rails.root.join("app/api/api.rb") if File.exist?(Rails.root.join("app/api/api.rb"))
  # load entities first
  load Rails.root.join("app/api/entities/user_entity.rb") if File.exist?(Rails.root.join("app/api/entities/user_entity.rb"))
  load Rails.root.join("app/api/entities/password_record_entity.rb") if File.exist?(Rails.root.join("app/api/entities/password_record_entity.rb"))
  load Rails.root.join("app/api/entities/shared_password_record_entity.rb") if File.exist?(Rails.root.join("app/api/entities/shared_password_record_entity.rb"))
  # Then load API components in a specific order
  # load Rails.root.join("app/api/v1/password_records.rb") if File.exist?(Rails.root.join("app/api/v1/password_records.rb"))
  load Rails.root.join("app/api/v1/password_records.rb") if File.exist?(Rails.root.join("app/api/v1/password_records.rb"))
  load Rails.root.join("app/api/v1/auth.rb") if File.exist?(Rails.root.join("app/api/v1/auth.rb"))
  load Rails.root.join("app/api/v1/shared_password_records.rb") if File.exist?(Rails.root.join("app/api/v1/shared_password_records.rb"))
  # load Rails.root.join("app/api/v1/shared_access.rb") if File.exist?(Rails.root.join("app/api/v1/shared_access.rb"))

  # Then load the base classes
  load Rails.root.join("app/api/v1/base.rb") if File.exist?(Rails.root.join("app/api/v1/base.rb"))
  load Rails.root.join("app/api/api.rb") if File.exist?(Rails.root.join("app/api/api.rb"))

  # Load any remaining API files
  Dir[Rails.root.join("app/api/**/*.rb")].sort.each do |file|
    next if file.include?("api.rb") || file.include?("v1/base.rb") ||
      file.include?("v1/helpers.rb") || file.include?("v1/password_records.rb") ||
      file.include?("v1/security.rb") || file.include?("v1/shared_access.rb")
    load file
  end
end
