require "test_helper"

class PasswordRecordTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end

  test "should not save password record without title" do
    password_record = PasswordRecord.find(980190962)
    puts password_record.errors.to_yaml
    assert_includes password_record.errors[:username], "username can't be blank"
    assert_includes password_record.errors[:url], "url must exist"
    assert_includes password_record.errors[:password], "password can't be blank"
    assert_includes password_record.errors[:title], "title can't be blank"
    assert_includes password_record.errors[:user_id], "user_id can't be blank"
  end

  test "should save valid password record" do
    user = User.new
    user = {}
  end
end
