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
User.destroy_all

unless User.where(role: :admin).exists?
  admin_emails = [ 'marco@gmail.com', 'raul@gmail.com']

  admin_emails.each do |email|
    user = User.create!(
      email: email,
      password: 'testtest',
      password_confirmation: 'testtest',
      role: :admin
    )
    puts "Admin user created with email: #{user.email}"
  end
  else
  puts "Admin users already exist. Skipping creation."
end

User.create!(
  email: "cedric@gmail.com",
  password: 'testtest',
  password_confirmation: 'testtest',
  role: :director
)

puts "Director user created."

User.create!(
  email: "alex@gmail.com",
  password: 'testtest',
  password_confirmation: 'testtest',
  role: :guest
)

puts "Guest user created."

# Ethnicity Setup
Ethnicity.destroy_all
%w[Caucasian Asian Black Hispanic Middle Eastern Native American Mixed Other].each do |ethnicity|
  Ethnicity.find_or_create_by(name: ethnicity)
end

puts "Ethnicity choices created."
