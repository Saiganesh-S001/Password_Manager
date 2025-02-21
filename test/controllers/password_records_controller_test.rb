require "test_helper"

class PasswordRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @password_record = password_records(:one)
  end

  test "should get index" do
    get password_records_url
    assert_response :success
  end

  test "should get new" do
    get new_password_record_url
    assert_response :success
  end

  test "should create password_record" do
    assert_difference("PasswordRecord.count") do
      post password_records_url, params: { password_record: { password: @password_record.password, url: @password_record.url, user_id: @password_record.user_id, username: @password_record.username } }
    end

    assert_redirected_to password_record_url(PasswordRecord.last)
  end

  test "should show password_record" do
    get password_record_url(@password_record)
    assert_response :success
  end

  test "should get edit" do
    get edit_password_record_url(@password_record)
    assert_response :success
  end

  test "should update password_record" do
    patch password_record_url(@password_record), params: { password_record: { password: @password_record.password, url: @password_record.url, user_id: @password_record.user_id, username: @password_record.username } }
    assert_redirected_to password_record_url(@password_record)
  end

  test "should destroy password_record" do
    assert_difference("PasswordRecord.count", -1) do
      delete password_record_url(@password_record)
    end

    assert_redirected_to password_records_url
  end
end
