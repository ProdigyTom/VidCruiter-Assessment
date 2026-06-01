require "test_helper"

class CrewsControllerTest < ActionDispatch::IntegrationTest
  test "GET /crews returns 200 with an array" do
    get "/crews"
    assert_response :ok

    body = JSON.parse(response.body)
    assert_kind_of Array, body
    assert_equal 1, body.first["id"]
    assert_equal "ABC123", body.first["title_id"]
    assert_equal "Ron Howard", body.first["directors"]
  end

  test "GET /crews/:id returns 200 with a single crew record" do
    get "/crews/1"
    assert_response :ok

    body = JSON.parse(response.body)
    assert_kind_of Hash, body
    assert_equal 1, body["id"]
    assert_equal "Ron Howard", body["directors"]
    assert_equal "John Smith,Jane Doe", body["writers"]
  end
end
