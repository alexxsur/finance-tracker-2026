require "test_helper"

class StocksControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test "search renders matching stock details" do
    stock = Stock.new(ticker: "AAPL", name: "Apple Inc", last_price: 123.45)

    Stock.stub(:new_lookup, stock) do
      get search_stock_path,
          params: { stock: "AAPL" },
          headers: { "Turbo-Frame" => "stock_search_results" }
    end

    assert_response :success
    assert_select "turbo-frame#stock_search_results"
    assert_select ".results-block", text: /AAPL/
    assert_select ".results-block", text: /Apple Inc/
    assert_select ".results-block", text: /\$123\.45/
    assert_select "form[action='#{user_stocks_path(ticker: "AAPL")}']"
  end

  test "search renders the full portfolio page without a Turbo Frame request" do
    stock = Stock.new(ticker: "AAPL", name: "Apple Inc", last_price: 123.45)

    Stock.stub(:new_lookup, stock) do
      get search_stock_path, params: { stock: "AAPL" }
    end

    assert_response :success
    assert_select "h1", "My Portfolio"
    assert_select "turbo-frame#stock_search_results .results-block", text: /AAPL/
  end

  test "search renders an error when ticker is blank" do
    get search_stock_path,
        params: { stock: " " },
        headers: { "Turbo-Frame" => "stock_search_results" }

    assert_response :success
    assert_select ".alert", text: "Please enter a symbol to search"
  end

  test "search renders an error when Twelve Data rejects the ticker" do
    Stock.stub(:new_lookup, ->(_ticker) { raise Stock::TwelveDataError, "Invalid symbol" }) do
      get search_stock_path,
          params: { stock: "INVALID" },
          headers: { "Turbo-Frame" => "stock_search_results" }
    end

    assert_response :success
    assert_select ".alert", text: "Invalid symbol"
  end

  test "search renders full-page errors without a Turbo Frame request" do
    Stock.stub(:new_lookup, ->(_ticker) { raise Stock::TwelveDataError, "Invalid symbol" }) do
      get search_stock_path, params: { stock: "INVALID" }
    end

    assert_response :success
    assert_select "h1", "My Portfolio"
    assert_select "turbo-frame#stock_search_results .alert", text: "Invalid symbol"
  end
end
