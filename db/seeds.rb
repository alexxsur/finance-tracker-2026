unless Rails.env.development? || Rails.env.test?
  abort "Example seeds are only available in development and test."
end

password = ENV.fetch("SEED_USER_PASSWORD") do
  raise "Set SEED_USER_PASSWORD to a password for the example users before running db:seed."
end
raise "SEED_USER_PASSWORD cannot be blank." if password.blank?

ActiveRecord::Base.transaction do
  users = {
    investor: { email: "investor@seed.example.com", first_name: "Alex", last_name: "Rivera" },
    beginner: { email: "beginner@seed.example.com", first_name: "Sam", last_name: "Taylor" },
    near_limit: { email: "near-limit@seed.example.com", first_name: "Jordan", last_name: "Lee" },
    at_limit: { email: "at-limit@seed.example.com", first_name: "Morgan", last_name: "Lee" },
    anonymous: { email: "anonymous@seed.example.com" }
  }.transform_values do |attributes|
    User.find_or_create_by!(email: attributes[:email]) do |user|
      user.assign_attributes(attributes.merge(password: password, password_confirmation: password))
    end
  end

  stocks = [
    [ "AAPL", "Apple Inc.", 190 ],
    [ "MSFT", "Microsoft Corporation", 420 ],
    [ "GOOGL", "Alphabet Inc.", 175 ],
    [ "AMZN", "Amazon.com Inc.", 185 ],
    [ "NVDA", "NVIDIA Corporation", 130 ],
    [ "META", "Meta Platforms Inc.", 500 ],
    [ "TSLA", "Tesla Inc.", 250 ],
    [ "JPM", "JPMorgan Chase & Co.", 210 ],
    [ "V", "Visa Inc.", 280 ],
    [ "KO", "Coca-Cola Company", 65 ],
    [ "DIS", "Walt Disney Company", 100 ]
  ].map do |ticker, name, price|
    Stock.check_db(ticker) || Stock.create!(ticker: ticker, name: name, last_price: price)
  end

  {
    investor: stocks.first(3),
    near_limit: stocks.first(9),
    at_limit: stocks.first(10)
  }.each do |user_key, portfolio|
    portfolio.each do |stock|
      UserStock.find_or_create_by!(user: users.fetch(user_key), stock: stock)
    end
  end

  [
    [ :investor, :near_limit ],
    [ :investor, :at_limit ],
    [ :near_limit, :investor ]
  ].each do |user_key, friend_key|
    Friendship.find_or_create_by!(user: users.fetch(user_key), friend: users.fetch(friend_key))
  end
end

puts "Example users, portfolios, and friendships are ready."
