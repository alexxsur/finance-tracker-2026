require "test_helper"

class StocksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test "search renders matching stock details" do
    stock = Stock.new(ticker: "AAPL", name: "Apple Inc", last_price: 123.45)

    Stock.stub(:new_lookup, stock) do
      get search_stock_path, params: { stock: "AAPL" }
    end

    assert_response :success
    assert_select ".results-block", text: /AAPL/
    assert_select ".results-block", text: /Apple Inc/
    assert_select ".results-block", text: /\$123\.45/
  end

  test "search redirects when ticker is blank" do
    get search_stock_path, params: { stock: " " }

    assert_redirected_to my_portfolio_path
    assert_equal "Please enter a symbol to search", flash[:alert]
  end

  test "search redirects when Twelve Data rejects the ticker" do
    Stock.stub(:new_lookup, ->(_ticker) { raise Stock::TwelveDataError, "Invalid symbol" }) do
      get search_stock_path, params: { stock: "INVALID" }
    end

    assert_redirected_to my_portfolio_path
    assert_equal "Invalid symbol", flash[:alert]
  end
end
