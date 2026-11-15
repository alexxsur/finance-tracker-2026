require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get my_portfolio" do
    sign_in users(:one)
    get my_portfolio_path
    assert_response :success
    assert_select "h1", "My Portfolio"
    assert_select "form[method=get] input[name=stock]"
    assert_select "table tbody tr", 1
    assert_select ".navbar-text", /Anonymous/
  end

  test "my_friends lists the current user's friends" do
    user = users(:one)
    sign_in user

    get my_friends_path

    assert_response :success
    assert_select "h1", "Friends"
    assert_select "table tbody tr", 1
    assert_select "table tbody tr", text: /#{users(:two).email}/
    assert_select "a.nav-link.active", "My Friends"
  end

  test "my_friends shows an empty state when the user has no friends" do
    user = users(:one)
    user.friendships.destroy_all
    sign_in user

    get my_friends_path

    assert_response :success
    assert_select "table", count: 0
    assert_select "p", "You aren't following anyone yet."
  end

  test "account update accepts first and last name" do
    user = users(:one)
    sign_in user

    patch user_registration_path, params: {
      user: {
        first_name: "Ada",
        last_name: "Lovelace",
        current_password: "password"
      }
    }

    assert_response :redirect
    assert_equal "Ada", user.reload.first_name
    assert_equal "Lovelace", user.last_name
  end

  test "profile edit form includes first and last name fields" do
    sign_in users(:one)
    get edit_user_registration_path

    assert_response :success
    assert_select "input[name='user[first_name]']"
    assert_select "input[name='user[last_name]']"
  end

  test "sign up form includes first and last name fields" do
    get new_user_registration_path

    assert_response :success
    assert_select "input[name='user[first_name]']"
    assert_select "input[name='user[last_name]']"
  end

  test "sign up saves first and last name" do
    assert_difference("User.count", 1) do
      post user_registration_path, params: {
        user: {
          first_name: "Ada",
          last_name: "Lovelace",
          email: "ada@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    user = User.find_by!(email: "ada@example.com")
    assert_equal "Ada", user.first_name
    assert_equal "Lovelace", user.last_name
  end
end
