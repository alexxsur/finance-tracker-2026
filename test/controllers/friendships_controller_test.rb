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
end
