require "test_helper"

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get index" do
    sign_in users(:one)
    get root_path
    assert_response :success
    assert_select "h1", "Make your investments easier to follow."
    assert_select "a[href='#{my_portfolio_path}']", "View my portfolio"
  end

  test "shows sign up and sign in links to visitors" do
    get root_path
    assert_response :success
    assert_select "a[href='#{new_user_registration_path}']", "Get started"
    assert_select "a[href='#{new_user_session_path}']", "Sign in"
  end
end
