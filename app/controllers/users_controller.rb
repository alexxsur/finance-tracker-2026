class UsersController < ApplicationController
  def my_portfolio
    @user = current_user
    @tracked_stocks = current_user.stocks
  end

  def show
    @user = User.find(params[:id])
    @tracked_stocks = @user.stocks
  end

  def my_friends
    @friends = current_user.friends
  end

  def search
    if params[:friend].blank?
      @search_error = "Please enter a friend name or email to search"
    else
      @search_results = current_user.except_current_user(User.search(params[:friend]))
      @search_error = "No users found matching your search" if @search_results.empty?
    end

    if request.headers["Turbo-Frame"] == "friend_search_results"
      render partial: "users/friend_search_results"
    else
      @friends = current_user.friends
      render "users/my_friends"
    end
  end
end
