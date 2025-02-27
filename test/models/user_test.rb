require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
  end

  test "user should be valid" do
    unless @user.valid?
      puts "User is not valid"
      puts @user.errors.full_messages
    end
    assert @user.valid?, "User is invalid: #{@user.errors.full_messages.join(', ')}"
  end

  test "email should be present" do
    @user.email = ""
    assert_not @user.valid?, "User is valid: #{@user.errors.full_messages.join(', ')}"
  end

  test "email should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email should be valid" do
    @user.email = "invalid_email"
    assert_not @user.valid?
  end

  test "password should be present" do
    @user.password = ""
    assert_not @user.valid?
  end

  test "password should be at least 8 characters" do
    @user.password = "short"
    @user.save
    puts @user.attributes.to_yaml
    assert_not @user.valid?
  end

  test "password should be encrypted before saving" do
    @user.password = "password"
    @user.save
    assert_not_nil @user.encrypted_password
    assert_not_equal "password", @user.encrypted_password
  end
end
