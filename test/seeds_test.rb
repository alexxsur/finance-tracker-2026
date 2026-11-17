require "test_helper"
require "securerandom"

class SeedsTest < ActiveSupport::TestCase
  test "example seeds cover portfolio and friendship scenarios without duplicates" do
    previous_password = ENV["SEED_USER_PASSWORD"]
    ENV["SEED_USER_PASSWORD"] = SecureRandom.hex(16)

    Rails.application.load_seed

    investor = User.find_by!(email: "investor@seed.example.com")
    beginner = User.find_by!(email: "beginner@seed.example.com")
    near_limit = User.find_by!(email: "near-limit@seed.example.com")
    at_limit = User.find_by!(email: "at-limit@seed.example.com")
    anonymous = User.find_by!(email: "anonymous@seed.example.com")

    assert investor.valid_password?(ENV.fetch("SEED_USER_PASSWORD"))
    assert_equal 3, investor.stocks.count
    assert_empty beginner.stocks
    assert_empty beginner.friends
    assert_equal 9, near_limit.stocks.count
    assert near_limit.under_stock_limit?
    assert_equal 10, at_limit.stocks.count
    assert_not at_limit.under_stock_limit?
    assert_equal "Anonymous", anonymous.full_name
    assert_empty anonymous.stocks
    assert_empty anonymous.friends
    assert_equal [ near_limit.id, at_limit.id ].sort, investor.friends.pluck(:id).sort
    assert_includes near_limit.friends, investor
    assert_not near_limit.friends.exists?(at_limit.id)
    assert investor.stock_already_tracked?("AAPL")
    assert investor.can_track_stock?("DIS")
    assert_includes User.search("Lee"), near_limit
    assert_includes User.search("Lee"), at_limit

    counts = [ User.count, Stock.count, UserStock.count, Friendship.count ]
    Rails.application.load_seed
    assert_equal counts, [ User.count, Stock.count, UserStock.count, Friendship.count ]
  ensure
    ENV["SEED_USER_PASSWORD"] = previous_password
  end

  test "example seeds preserve existing users and reuse stocks regardless of ticker case" do
    previous_password = ENV["SEED_USER_PASSWORD"]
    ENV["SEED_USER_PASSWORD"] = SecureRandom.hex(16)
    original_password = SecureRandom.hex(16)
    user = User.create!(email: "investor@seed.example.com", first_name: "Existing", password: original_password)
    stock = stocks(:one)
    stock.update!(ticker: "aapl")

    Rails.application.load_seed

    assert_equal "Existing", user.reload.first_name
    assert user.valid_password?(original_password)
    assert_not user.valid_password?(ENV.fetch("SEED_USER_PASSWORD"))
    assert_equal 1, Stock.where("LOWER(ticker) = ?", "aapl").count
    assert_includes user.stocks, stock
  ensure
    ENV["SEED_USER_PASSWORD"] = previous_password
  end

  test "example seeds require a nonblank password" do
    previous_password = ENV.delete("SEED_USER_PASSWORD")

    [ nil, " " ].each do |password|
      ENV["SEED_USER_PASSWORD"] = password
      error = assert_raises(RuntimeError) { Rails.application.load_seed }
      assert_match "SEED_USER_PASSWORD", error.message
      assert_not User.exists?(email: "investor@seed.example.com")
    end
  ensure
    ENV["SEED_USER_PASSWORD"] = previous_password
  end
end
