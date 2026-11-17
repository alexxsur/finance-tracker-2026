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

  test "my_portfolio shows an empty state when the user has no stocks" do
    user = users(:one)
    user.user_stocks.destroy_all
    sign_in user

    get my_portfolio_path

    assert_response :success
    assert_select "p", "Your portfolio is empty. Search for a stock above to add your first one."
    assert_select "table", count: 0
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

  test "show displays another user's profile and portfolio" do
    users(:one).friendships.destroy_all
    sign_in users(:one)
    get user_path(users(:two))

    assert_response :success
    assert_select "h1", users(:two).full_name
    assert_select "p", users(:two).email
    assert_select "table tbody tr", 1
    assert_select "button", "Follow friend"
    assert_select "a.btn-primary[href='#{my_friends_path}']", "Back"
  end

  test "show profile allows adding another user's stock to the current portfolio" do
    sign_in users(:one)
    get user_path(users(:two))

    assert_response :success
    assert_select "table tbody tr form[action=?]", user_stocks_path(ticker: stocks(:two).ticker) do
      assert_select "button.btn-sm", "Add to portfolio"
    end
  end

  test "show profile marks an already followed user" do
    sign_in users(:one)
    get user_path(users(:two))

    assert_response :success
    assert_select ".badge", "You are friends"
  end

  test "show profile displays an empty portfolio state" do
    user = users(:two)
    user.user_stocks.destroy_all
    sign_in users(:one)

    get user_path(user)

    assert_response :success
    assert_select "p", "No stocks in this portfolio yet."
  end

  test "friends list links to each friend's profile" do
    sign_in users(:one)
    get my_friends_path

    assert_response :success
    assert_select "a[href='#{user_path(users(:two))}']", "View Profile"
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

  test "search returns matching users and excludes the current user in the Turbo Frame" do
    current_user = users(:one)
    friend = users(:two)
    friend.update!(first_name: "Ada", last_name: "Lovelace")
    current_user.update!(first_name: "Ada", last_name: "Byron")
    sign_in current_user

    get search_friend_path,
        params: { friend: "Ada" },
        headers: { "Turbo-Frame" => "friend_search_results" }

    assert_response :success
    assert_select "turbo-frame#friend_search_results", text: /Ada Lovelace/
    assert_select "turbo-frame#friend_search_results", text: /#{friend.email}/
    assert_select "turbo-frame#friend_search_results", text: /#{current_user.email}/, count: 0
    assert_select "turbo-frame#friend_search_results", text: /You are friends/
    assert_select "form[action='#{friendships_path}']", count: 0
  end

  test "search renders matching users without a Turbo Frame" do
    result = User.create!(first_name: "Ada", last_name: "Lovelace",
                          email: "ada@example.com", password: "password")
    sign_in users(:one)
    get search_friend_path, params: { friend: result.email }

    assert_response :success
    assert_select "h1", "Friends"
    assert_select "turbo-frame#friend_search_results table tbody tr", text: /#{result.email}/
    assert_select "turbo-frame#friend_search_results", text: /Ada Lovelace/
    assert_select "turbo-frame#friend_search_results", text: /Follow friend/
    assert_select "table tbody tr", text: /#{users(:two).email}/
  end

  test "search displays a friendly error for a blank Turbo Frame query" do
    sign_in users(:one)
    get search_friend_path,
        params: { friend: " " },
        headers: { "Turbo-Frame" => "friend_search_results" }

    assert_response :success
    assert_select ".alert", "Please enter a friend name or email to search"
  end

  test "search displays a message when no users match" do
    sign_in users(:one)
    get search_friend_path,
        params: { friend: "no-such-user" },
        headers: { "Turbo-Frame" => "friend_search_results" }

    assert_response :success
    assert_select ".alert", "No users found matching your search"
  end

  test "friend search offers a follow action for users not followed yet" do
    friend = users(:two)
    friend.update!(first_name: "Ada", last_name: "Lovelace")
    users(:one).friendships.destroy_all
    sign_in users(:one)

    get search_friend_path,
        params: { friend: "Ada" },
        headers: { "Turbo-Frame" => "friend_search_results" }

    assert_response :success
    assert_select "form[action='#{friendships_path}'][method=post][data-turbo-frame='_top']" do
      assert_select "input[type=hidden][name=friend][value='#{friend.id}']"
      assert_select "button[type=submit]", "Follow friend"
    end

    assert_difference("Friendship.count", 1) do
      post friendships_path, params: { friend: friend.id }
    end
    assert_redirected_to my_friends_path
    follow_redirect!
    assert_select "table tbody tr", text: /#{friend.email}/
  end

  test "search displays errors without a Turbo Frame and keeps the friends list" do
    sign_in users(:one)

    { " " => "Please enter a friend name or email to search",
      "no-such-user" => "No users found matching your search" }.each do |query, message|
      get search_friend_path, params: { friend: query }

      assert_response :success
      assert_select "turbo-frame#friend_search_results .alert", message
      assert_select "table tbody tr", text: /#{users(:two).email}/
    end
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

  test "sign in page is reachable alongside user profiles" do
    get new_user_session_path

    assert_response :success
    assert_select "form[action='#{user_session_path}']"
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
