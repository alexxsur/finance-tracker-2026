class FriendshipsController < ApplicationController
  def create
    friend = User.find(params[:friend])

    if friend == current_user
      redirect_to my_friends_path, alert: "You cannot follow yourself."
      return
    end

    if current_user.friends.exists?(friend.id)
      redirect_to my_friends_path, alert: "You are already following this user."
      return
    end

    friendship = current_user.friendships.build(friend: friend)
    if friendship.save
      redirect_to my_friends_path, notice: "You are now following #{friend.full_name}."
    else
      redirect_to my_friends_path, alert: "There was a problem following this user."
    end
  end

  def destroy
    friendship = current_user.friendships.find(params[:id])
    friend_name = friendship.friend.full_name
    friendship.destroy!

    redirect_to my_friends_path, notice: "Stopped following #{friend_name}."
  end
end
