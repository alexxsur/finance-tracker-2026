require "test_helper"

class FriendshipsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test "stops following a friend belonging to the current user" do
    friendship = friendships(:one)

    assert_difference("Friendship.count", -1) do
      delete friendship_path(friendship)
    end

    assert_redirected_to my_friends_path
    assert_equal "Stopped following #{users(:two).full_name}.", flash[:notice]
    assert_not users(:one).friends.exists?(users(:two).id)
  end

  test "cannot stop following another user's friend" do
    friendship = friendships(:two)

    assert_no_difference("Friendship.count") do
      delete friendship_path(friendship)
    end

    assert_response :not_found
    assert Friendship.exists?(friendship.id)
  end

  test "follows another user from the current user's account" do
    friend = users(:two)
    Friendship.where(user: users(:one), friend: friend).delete_all

    assert_difference("Friendship.count", 1) do
      post friendships_path, params: { friend: friend.id }
    end

    assert_redirected_to my_friends_path
    assert_equal "You are now following #{friend.full_name}.", flash[:notice]
    assert users(:one).friends.exists?(friend.id)
  end

  test "does not create a duplicate follow" do
    assert_no_difference("Friendship.count") do
      post friendships_path, params: { friend: users(:two).id }
    end

    assert_redirected_to my_friends_path
    assert_equal "You are already following this user.", flash[:alert]
  end

  test "cannot follow yourself" do
    assert_no_difference("Friendship.count") do
      post friendships_path, params: { friend: users(:one).id }
    end

    assert_redirected_to my_friends_path
    assert_equal "You cannot follow yourself.", flash[:alert]
  end
end
