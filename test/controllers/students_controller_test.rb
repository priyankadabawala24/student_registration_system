require "test_helper"

class StudentsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get students_show_url
    assert_response :success
  end

  test "should get pending_verification" do
    get students_pending_verification_url
    assert_response :success
  end
end
