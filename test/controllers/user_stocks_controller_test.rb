require "test_helper"

class UserStocksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test "adds an existing stock to the current user's portfolio" do
    stock = stocks(:two)

    assert_difference("UserStock.count", 1) do
      post user_stocks_path, params: { ticker: stock.ticker }
    end

    assert_redirected_to my_portfolio_path
    assert_equal "Stock #{stock.name} was successfully added to your portfolio", flash[:notice]
    assert_includes users(:one).stocks, stock
  end

  test "looks up and saves a stock that is not already in the database" do
    stock = Stock.new(ticker: "NVDA", name: "NVIDIA Corporation", last_price: 123.45)

    Stock.stub(:new_lookup, stock) do
      assert_difference([ "Stock.count", "UserStock.count" ], 1) do
        post user_stocks_path, params: { ticker: "NVDA" }
      end
    end

    assert_redirected_to my_portfolio_path
    assert_equal "Stock NVIDIA Corporation was successfully added to your portfolio", flash[:notice]
  end

  test "does not add a stock when no ticker is provided" do
    assert_no_difference([ "Stock.count", "UserStock.count" ]) do
      post user_stocks_path, params: { ticker: "" }
    end

    assert_redirected_to my_portfolio_path
    assert_equal "Please enter a symbol to add", flash[:alert]
  end

  test "shows Twelve Data errors without adding a stock" do
    Stock.stub(:new_lookup, ->(_ticker) { raise Stock::TwelveDataError, "Invalid symbol" }) do
      assert_no_difference([ "Stock.count", "UserStock.count" ]) do
        post user_stocks_path, params: { ticker: "INVALID" }
      end
    end

    assert_redirected_to my_portfolio_path
    assert_equal "Invalid symbol", flash[:alert]
  end

  test "does not add the same stock to a user's portfolio twice" do
    stock = stocks(:one)

    assert_no_difference("UserStock.count") do
      post user_stocks_path, params: { ticker: stock.ticker }
    end

    assert_redirected_to my_portfolio_path
    assert_equal "You are already tracking this stock.", flash[:alert]
  end

  test "prevents adding more than ten different stocks" do
    user = users(:one)
    (10 - user.stocks.count).times do |index|
      stock = Stock.create!(ticker: "LIMIT#{index}", name: "Limit stock #{index}")
      user.stocks << stock
    end
    assert_no_difference([ "Stock.count", "UserStock.count" ]) do
      post user_stocks_path, params: { ticker: "EXTRA" }
    end

    assert_redirected_to my_portfolio_path
    assert_equal "You can track up to 10 stocks.", flash[:alert]
  end

  test "removes a stock from the current user's portfolio" do
    user_stock = users(:one).user_stocks.find_by!(stock: stocks(:one))
    stock = user_stock.stock

    assert_no_difference("Stock.count") do
      assert_difference("UserStock.count", -1) do
        delete user_stock_path(user_stock)
      end
    end

    assert_redirected_to my_portfolio_path
    assert_equal "#{stock.ticker} was successfully removed from your portfolio", flash[:notice]
  end

  test "cannot remove another user's stock association" do
    user_stock = users(:two).user_stocks.find_by!(stock: stocks(:two))

    assert_no_difference("UserStock.count") do
      delete user_stock_path(user_stock)
    end

    assert_response :not_found
    assert UserStock.exists?(user_stock.id)
  end
end
