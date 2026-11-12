class UserStocksController < ApplicationController
  def create
    ticker = params[:ticker].to_s.strip
    if ticker.blank?
      redirect_to my_portfolio_path, alert: "Please enter a symbol to add"
      return
    end

    stock = Stock.check_db(ticker)
    unless stock
      stock = Stock.new_lookup(ticker)
      unless stock.save
        redirect_to my_portfolio_path, alert: stock.errors.full_messages.to_sentence
        return
      end
    end

    user_stock = current_user.user_stocks.build(stock: stock)
    unless user_stock.save
      redirect_to my_portfolio_path, alert: user_stock.errors.full_messages.to_sentence
      return
    end

    redirect_to my_portfolio_path, notice: "Stock #{stock.name} was successfully added to your portfolio"
  rescue Stock::TwelveDataError => error
    redirect_to my_portfolio_path, alert: error.message
  end
end
