require "test_helper"

class SharedAccessControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get shared_access_create_url
    assert_response :success
  end

  test "should get destroy" do
    get shared_access_destroy_url
    assert_response :success
  end
end
