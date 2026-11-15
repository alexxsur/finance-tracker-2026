require "test_helper"

class FriendshipTest < ActiveSupport::TestCase
  test "belongs to a user and a friend" do
    friendship = friendships(:one)

    assert_equal users(:one), friendship.user
    assert_equal users(:two), friendship.friend
  end

  test "user can access friends through friendships" do
    assert_includes users(:one).friends, users(:two)
  end
end
