require "test_helper"

class RatingsControllerTest < ActionDispatch::IntegrationTest
  test "GET /ratings returns 200 with an array" do
    get "/ratings"
    assert_response :ok

    body = JSON.parse(response.body)
    assert_kind_of Array, body
    assert_equal 1, body.first["id"]
    assert_equal "ABC123", body.first["title_id"]
    assert_equal 6.5, body.first["average_rating"]
  end

  test "GET /ratings/:id returns 200 with a single rating" do
    get "/ratings/1"
    assert_response :ok

    body = JSON.parse(response.body)
    assert_kind_of Hash, body
    assert_equal 1, body["id"]
    assert_equal "ABC123", body["title_id"]
    assert_equal 194, body["number_of_votes"]
  end
end
