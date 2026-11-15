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

  test "my_friends includes a Turbo-powered friend search form" do
    sign_in users(:one)
    get my_friends_path

    assert_response :success
    assert_select "form[action='#{search_friend_path}'][data-turbo-frame='friend_search_results']" do
      assert_select "input[name=friend][placeholder='Name or email']"
      assert_select "button[type=submit] i.bi-search"
    end
    assert_select "turbo-frame#friend_search_results"
  end

  test "search returns the submitted friend query in the Turbo Frame" do
    sign_in users(:one)
    get search_friend_path,
        params: { friend: "Ada Lovelace" },
        headers: { "Turbo-Frame" => "friend_search_results" }

    assert_response :success
    assert_select "turbo-frame#friend_search_results", text: /Ada Lovelace/
  end

  test "search returns the submitted friend query as JSON without a Turbo Frame" do
    sign_in users(:one)
    get search_friend_path, params: { friend: "ada@example.com" }

    assert_response :success
    assert_equal '"ada@example.com"', response.body
  end

  test "search displays a friendly error for a blank Turbo Frame query" do
    sign_in users(:one)
    get search_friend_path,
        params: { friend: " " },
        headers: { "Turbo-Frame" => "friend_search_results" }

    assert_response :success
    assert_select ".alert", "Please enter a friend name or email to search"
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
