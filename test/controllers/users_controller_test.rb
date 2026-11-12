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
  end
end
