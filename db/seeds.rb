# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Remove an existing admin safely

# User Setup
# === User Setup ===
if Rails.env.development? || Rails.env.test?
  User.destroy_all
  puts "Users destroyed in #{Rails.env} environment."
end

admin_emails = ['marco@gmail.com', 'raul@gmail.com']
admin_emails.each do |email|
  user = User.find_or_create_by!(email: email) do |u|
    u.password = 'testtest'
    u.password_confirmation = 'testtest'
    u.role = :admin
  end
  puts "Ensured admin user: #{user.email}"
end

[
  { email: 'cedric@gmail.com', role: :director },
  { email: 'alex@gmail.com', role: :guest }
].each do |attrs|
  user = User.find_or_create_by!(email: attrs[:email]) do |u|
    u.password = 'testtest'
    u.password_confirmation = 'testtest'
    u.role = attrs[:role]
  end
  puts "Ensured #{attrs[:role]} user: #{user.email}"
end

# === Ethnicity Setup ===
Ethnicity.destroy_all if Rails.env.development? || Rails.env.test?
%w[Caucasian Asian Black Hispanic Middle Eastern Native American Mixed Other].each do |ethnicity|
  Ethnicity.find_or_create_by!(name: ethnicity)
end
puts "Ethnicity choices created."
