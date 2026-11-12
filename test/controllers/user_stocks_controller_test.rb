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
end
