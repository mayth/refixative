namespace :admin do
  desc 'Add the user'
  task create_user: :environment do
    email = ENV['email'].presence
    fail "No email address. Specify `email'." unless email
    password = ENV['password'].presence
    fail "No password. Specify `password'." unless password
    Admin.create(
      email: email,
      password: password
    )
  end
end