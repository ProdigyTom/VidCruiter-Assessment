require "test_helper"

class TitlesControllerTest < ActionDispatch::IntegrationTest
  test "GET /titles returns 200 with an array" do
    get "/titles"
    assert_response :ok

    body = JSON.parse(response.body)
    assert_kind_of Array, body
    assert_includes body.first, "id"
    assert_includes body.first, "primary_title"
    assert_equal "ABC123", body.first["id"]
    assert_equal "The Godfather", body.first["primary_title"]
  end

  test "GET /titles/:id returns 200 with a single title" do
    get "/titles/ABC123"
    assert_response :ok

    body = JSON.parse(response.body)
    assert_kind_of Hash, body
    assert_equal "ABC123", body["id"]
    assert_equal "The Godfather", body["primary_title"]
    assert_equal 1972, body["start_year"]
  end
end
