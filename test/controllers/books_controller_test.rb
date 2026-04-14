require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @book = books(:one)
  end

  test "should get index" do
    get root_url
    assert_response :success
  end

  test "should get show" do
    get book_url(@book)
    assert_response :success
  end

  test "edit redirects to login when not signed in" do
    get edit_book_url(@book)
    assert_redirected_to login_path
  end

  test "edit succeeds when signed in" do
    post login_url, params: { email: users(:admin).email, password: "secret" }
    get edit_book_url(@book)
    assert_response :success
  end
end
