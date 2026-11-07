class StocksController < ApplicationController
  def search
    if params[:stock].blank?
      redirect_to my_portfolio_path, alert: "Please enter a symbol to search"
      return
    end

    @stock = Stock.new_lookup(params[:stock])
    render "users/my_portfolio"
  rescue Stock::TwelveDataError => error
    redirect_to my_portfolio_path, alert: error.message
  end
end
