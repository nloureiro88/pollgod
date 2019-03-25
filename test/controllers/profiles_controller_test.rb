require 'test_helper'

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get dash" do
    get profiles_dash_url
    assert_response :success
  end

  test "should get filter_toggle" do
    get profiles_filter_toggle_url
    assert_response :success
  end

end
