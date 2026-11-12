class StocksController < ApplicationController
  def search
    if params[:stock].blank?
      @search_error = "Please enter a symbol to search"
      render_search_response
      return
    end

    @stock = Stock.new_lookup(params[:stock])
    render_search_response
  rescue Stock::TwelveDataError => error
    @search_error = error.message
    render_search_response
  end

  private

  def render_search_response
    if request.headers["Turbo-Frame"].present?
      render partial: "users/stock_search_results"
    else
      @tracked_stocks = current_user.stocks
      render "users/my_portfolio"
    end
  end
end
