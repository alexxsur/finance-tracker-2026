require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "detects when a user is already tracking a stock" do
    assert users(:one).stock_already_tracked?(stocks(:one).ticker)
    assert_not users(:one).stock_already_tracked?(stocks(:two).ticker)
  end

  test "allows tracking fewer than ten stocks" do
    assert users(:one).under_stock_limit?
  end

  test "reports the stock limit as reached at ten stocks" do
    user = users(:one)
    (10 - user.stocks.count).times do |index|
      stock = Stock.create!(ticker: "LIMIT#{index}", name: "Limit stock #{index}")
      user.stocks << stock
    end

    assert_not user.under_stock_limit?
  end

  test "can track a stock only when not already tracked and under the limit" do
    user = users(:one)

    assert_not user.can_track_stock?(stocks(:one).ticker)
    assert user.can_track_stock?("NEW-TICKER")
  end

  test "full_name joins first and last names" do
    user = users(:one)
    user.first_name = "Ada"
    user.last_name = "Lovelace"

    assert_equal "Ada Lovelace", user.full_name
  end

  test "full_name falls back to Anonymous when no name is set" do
    assert_equal "Anonymous", users(:one).full_name
  end
end
