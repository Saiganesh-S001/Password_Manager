require "test_helper"

class PasswordRecordTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @password_record = password_records(:one)
  end

  test "password record should be valid" do
    assert @password_record.valid?
  end

  test "password record password should be encrypted" do
    puts @password_record.attributes.to_yaml
    assert_not_nil @password_record.password
    assert_not_equal "MyString", @password_record.password
  end

  test "user should be able to create password record" do
    record = @user.password_records.create(
      title: "Unique Test Title 1",
      username: "Test",
      password: "Test",
      url: "http://Test.com"
    )

    puts record.errors.full_messages # Debugging output

    assert record.persisted?, "Record was not saved due to validation errors"
  end
end
