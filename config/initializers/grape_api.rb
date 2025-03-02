# Disable Zeitwerk for our API paths
Rails.autoloaders.main.ignore(Rails.root.join('app/api'))

# Manual loading for our API files in the correct order
Rails.application.config.to_prepare do
  # First load module definitions
  load Rails.root.join('app/api/root/v1.rb') if File.exist?(Rails.root.join('app/api/root/v1.rb'))

  # Then load API components in a specific order
  load Rails.root.join('app/api/root/v1/password_records.rb') if File.exist?(Rails.root.join('app/api/root/v1/password_records.rb'))
  load Rails.root.join('app/api/root/v1/security.rb') if File.exist?(Rails.root.join('app/api/root/v1/security.rb'))
  load Rails.root.join('app/api/root/v1/shared_access.rb') if File.exist?(Rails.root.join('app/api/root/v1/shared_access.rb'))

  # Then load the base classes
  load Rails.root.join('app/api/root/v1/base.rb') if File.exist?(Rails.root.join('app/api/root/v1/base.rb'))
  load Rails.root.join('app/api/root/base.rb') if File.exist?(Rails.root.join('app/api/root/base.rb'))

  # Load any remaining API files
  Dir[Rails.root.join('app/api/**/*.rb')].sort.each do |file|
    next if file.include?('root/base.rb') || file.include?('root/v1/base.rb') ||
      file.include?('root/v1/helpers.rb') || file.include?('root/v1/password_records.rb') ||
      file.include?('root/v1/security.rb') || file.include?('root/v1/shared_access.rb')
    load file
  end
end