namespace :users do
  desc "Add encryption keys to users who don't have one"
  task add_encryption_keys: :environment do
    User.transaction do
      users_to_update = User.where(encryption_key: [ nil, "" ])

      puts "Found #{users_to_update.count} users without encryption keys"

      users_to_update.each do |user|
        begin
          user.update_column(:encryption_key, SecureRandom.hex(32))
          print "."
        rescue => e
          puts "\nError updating user #{user.id}: #{e.message}"
        end
      end

      puts "\nCompleted! Updated #{users_to_update.count} users"
    end
  end
end
