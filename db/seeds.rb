# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

if ENV["ADMIN_EMAIL"].present? && ENV["ADMIN_PASSWORD"].present?
  User.find_or_initialize_by(email: ENV["ADMIN_EMAIL"].strip.downcase).tap do |user|
    user.password = ENV["ADMIN_PASSWORD"]
    user.password_confirmation = ENV["ADMIN_PASSWORD"]
    user.save!
  end
elsif Rails.env.development?
  User.find_or_initialize_by(email: "admin@localhost").tap do |user|
    user.password = "changeme"
    user.password_confirmation = "changeme"
    user.save!
  end
  puts "Seeded admin user: admin@localhost / changeme"
end
