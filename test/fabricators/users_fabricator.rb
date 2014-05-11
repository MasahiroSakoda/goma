Fabricator(:user) do
  username { sequence(:username) { |i| "user#{i}" } }
  email { sequence(:email) { |i| "user#{i}@example.com" } }
  password 'password'
  password_confirmation 'password'
  activated_at Time.new.utc
end

Fabricator(:unactivated_user, from: :user) do
  activated_at nil
end
