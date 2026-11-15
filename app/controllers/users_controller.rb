class UsersController < ApplicationController
  def my_portfolio
    @tracked_stocks = current_user.stocks
  end

  def my_friends
    @friends = current_user.friends
  end

  def search
    @friend_query = params[:friend]

    if request.headers["Turbo-Frame"] == "friend_search_results"
      render partial: "users/friend_search_results"
    else
      render json: @friend_query.to_json
    end
  end
end
