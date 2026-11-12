require "json"
require "net/http"

class Stock < ApplicationRecord
  has_many :user_stocks
  has_many :users, through: :user_stocks

  validates :name, :ticker, presence: true

  class TwelveDataError < StandardError; end

  API_URL = "https://api.twelvedata.com/quote"

  def self.check_db(ticker_symbol)
    where("LOWER(ticker) = ?", ticker_symbol.to_s.strip.downcase).first
  end

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
      if response.is_a?(Net::HTTPNotFound)
        raise TwelveDataError, "We couldn't find that symbol. Check the ticker and try again."
      end

      raise TwelveDataError, "Twelve Data request failed with HTTP status #{response.code}"
    end

    data = begin
      JSON.parse(response.body)
    rescue JSON::ParserError
      raise TwelveDataError, "Twelve Data returned an invalid JSON response"
    end
    if data["status"] == "error"
      raise TwelveDataError, data["message"].presence || "Twelve Data did not return a price"
    end

    if data["symbol"].blank? || data["name"].blank? || data["close"].blank?
      raise TwelveDataError, "Twelve Data did not return complete stock details"
    end

    begin
      new(ticker: data["symbol"], name: data["name"], last_price: BigDecimal(data["close"].to_s))
    rescue ArgumentError
      raise TwelveDataError, "Twelve Data returned an invalid price"
    end
  end
end
