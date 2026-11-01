require "json"
require "net/http"

class Stock < ApplicationRecord
  class TwelveDataError < StandardError; end

  API_URL = "https://api.twelvedata.com/price"

  def self.new_lookup(ticker_symbol)
    symbol = ticker_symbol.to_s.strip
    raise ArgumentError, "Ticker symbol must be present" if symbol.empty?

    api_key = Rails.application.credentials.dig(:twelve_data, :api_key)
    raise TwelveDataError, "Twelve Data API key is missing" if api_key.blank?

    uri = URI(API_URL)
    uri.query = URI.encode_www_form(symbol: symbol, apikey: api_key)
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 10) do |http|
      http.get(uri.request_uri)
    end

    unless response.is_a?(Net::HTTPSuccess)
      raise TwelveDataError, "Twelve Data request failed with HTTP status #{response.code}"
    end

    data = JSON.parse(response.body)
    if data["status"] == "error" || data["price"].blank?
      raise TwelveDataError, data["message"].presence || "Twelve Data did not return a price"
    end

    begin
      BigDecimal(data["price"])
    rescue ArgumentError
      raise TwelveDataError, "Twelve Data returned an invalid price"
    end
  rescue JSON::ParserError
    raise TwelveDataError, "Twelve Data returned an invalid JSON response"
  end
end
