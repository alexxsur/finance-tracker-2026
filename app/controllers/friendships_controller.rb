class FriendshipsController < ApplicationController
  def create
    head :not_implemented
  end

  def destroy
    friendship = current_user.friendships.find(params[:id])
    friend_name = friendship.friend.full_name
    friendship.destroy!

    redirect_to my_friends_path, notice: "Stopped following #{friend_name}."
  end
end
