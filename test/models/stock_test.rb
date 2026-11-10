require "test_helper"
require "minitest/mock"

class StockTest < ActiveSupport::TestCase
  test "new_lookup returns stock details from Twelve Data" do
    response = Net::HTTPOK.new("1.1", "200", "OK")
    response.instance_variable_set(:@read, true)
    response.instance_variable_set(:@body, '{"symbol":"AAPL","name":"Apple Inc","close":"123.45"}')

    http = Object.new
    test_case = self
    http.define_singleton_method(:get) do |path|
      test_case.assert_equal "/quote?symbol=AAPL&apikey=test-api-key", path
      response
    end
    start_http = ->(_host, _port, **_options, &block) { block.call(http) }

    Rails.application.credentials.stub(:dig, "test-api-key") do
      Net::HTTP.stub(:start, start_http) do
        stock = Stock.new_lookup("AAPL")
        assert_equal "AAPL", stock.ticker
        assert_equal "Apple Inc", stock.name
        assert_equal BigDecimal("123.45"), stock.last_price
      end
    end
  end

  test "new_lookup rejects a blank ticker" do
    assert_raises(ArgumentError) { Stock.new_lookup(" ") }
  end

  test "new_lookup raises when the API key is missing" do
    Rails.application.credentials.stub(:dig, nil) do
      error = assert_raises(Stock::TwelveDataError) { Stock.new_lookup("AAPL") }
      assert_equal "Twelve Data API key is missing", error.message
    end
  end

  test "new_lookup raises when Twelve Data returns an API error" do
    response = Net::HTTPOK.new("1.1", "200", "OK")
    response.instance_variable_set(:@read, true)
    response.instance_variable_set(:@body, '{"status":"error","message":"Invalid symbol"}')

    http = Object.new
    http.define_singleton_method(:get) { |_path| response }
    start_http = ->(_host, _port, **_options, &block) { block.call(http) }

    Rails.application.credentials.stub(:dig, "test-api-key") do
      Net::HTTP.stub(:start, start_http) do
        error = assert_raises(Stock::TwelveDataError) { Stock.new_lookup("INVALID") }
        assert_equal "Invalid symbol", error.message
      end
    end
  end

  test "new_lookup raises when Twelve Data omits stock details" do
    response = Net::HTTPOK.new("1.1", "200", "OK")
    response.instance_variable_set(:@read, true)
    response.instance_variable_set(:@body, '{"symbol":"AAPL","name":"Apple Inc"}')

    http = Object.new
    http.define_singleton_method(:get) { |_path| response }
    start_http = ->(_host, _port, **_options, &block) { block.call(http) }

    Rails.application.credentials.stub(:dig, "test-api-key") do
      Net::HTTP.stub(:start, start_http) do
        error = assert_raises(Stock::TwelveDataError) { Stock.new_lookup("AAPL") }
        assert_equal "Twelve Data did not return complete stock details", error.message
      end
    end
  end

  test "new_lookup shows a friendly message when Twelve Data returns not found" do
    response = Net::HTTPNotFound.new("1.1", "404", "Not Found")
    response.instance_variable_set(:@read, true)
    response.instance_variable_set(:@body, "")

    http = Object.new
    http.define_singleton_method(:get) { |_path| response }
    start_http = ->(_host, _port, **_options, &block) { block.call(http) }

    Rails.application.credentials.stub(:dig, "test-api-key") do
      Net::HTTP.stub(:start, start_http) do
        error = assert_raises(Stock::TwelveDataError) { Stock.new_lookup("INVALID") }
        assert_equal "We couldn't find that symbol. Check the ticker and try again.", error.message
      end
    end
  end
end
