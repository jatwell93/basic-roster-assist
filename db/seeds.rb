# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Test users for development and testing
puts "Creating test users..."

# Admin user
User.find_or_create_by!(email: "admin@example.com") do |user|
  user.role = "admin"
  user.pin = "1234"
  user.hourly_rate = 50.00
  user.password = "password123"
  user.password_confirmation = "password123"
end

# Manager user
User.find_or_create_by!(email: "manager@example.com") do |user|
  user.role = "manager"
  user.pin = "5678"
  user.hourly_rate = 35.00
  user.password = "password123"
  user.password_confirmation = "password123"
end

# Staff users
User.find_or_create_by!(email: "staff1@example.com") do |user|
  user.role = "staff"
  user.pin = "1111"
  user.hourly_rate = 25.00
  user.password = "password123"
  user.password_confirmation = "password123"
end

User.find_or_create_by!(email: "staff2@example.com") do |user|
  user.role = "staff"
  user.pin = "2222"
  user.hourly_rate = 28.00
  user.password = "password123"
  user.password_confirmation = "password123"
end

User.find_or_create_by!(email: "staff3@example.com") do |user|
  user.role = "staff"
  user.pin = "3333"
  user.hourly_rate = 26.50
  user.password = "password123"
  user.password_confirmation = "password123"
end

puts "Test users created successfully!"
puts ""
puts "Login credentials for testing:"
puts "Admin:    admin@example.com    / password123    / PIN: 1234"
puts "Manager:  manager@example.com  / password123    / PIN: 5678"
puts "Staff1:   staff1@example.com   / password123    / PIN: 1111"
puts "Staff2:   staff2@example.com   / password123    / PIN: 2222"
puts "Staff3:   staff3@example.com   / password123    / PIN: 3333"
puts ""
puts "To load these users, run: bin/rails db:seed"
