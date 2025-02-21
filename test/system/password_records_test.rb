require "application_system_test_case"

class PasswordRecordsTest < ApplicationSystemTestCase
  setup do
    @password_record = password_records(:one)
  end

  test "visiting the index" do
    visit password_records_url
    assert_selector "h1", text: "Password records"
  end

  test "should create password record" do
    visit password_records_url
    click_on "New password record"

    fill_in "Password", with: @password_record.password
    fill_in "Url", with: @password_record.url
    fill_in "User", with: @password_record.user_id
    fill_in "Username", with: @password_record.username
    click_on "Create Password record"

    assert_text "Password record was successfully created"
    click_on "Back"
  end

  test "should update Password record" do
    visit password_record_url(@password_record)
    click_on "Edit this password record", match: :first

    fill_in "Password", with: @password_record.password
    fill_in "Url", with: @password_record.url
    fill_in "User", with: @password_record.user_id
    fill_in "Username", with: @password_record.username
    click_on "Update Password record"

    assert_text "Password record was successfully updated"
    click_on "Back"
  end

  test "should destroy Password record" do
    visit password_record_url(@password_record)
    click_on "Destroy this password record", match: :first

    assert_text "Password record was successfully destroyed"
  end
end
