require "test_helper"

class PrincipalsControllerTest < ActionDispatch::IntegrationTest
  test "GET /principals returns 200 with an array" do
    get "/principals"
    assert_response :ok

    body = JSON.parse(response.body)
    assert_kind_of Array, body
    assert_equal 1, body.first["id"]
    assert_equal "ABC123", body.first["title_id"]
    assert_equal "XYZ789", body.first["name_id"]
    assert_equal "actor", body.first["category"]
  end

  test "GET /principals/:id returns 200 with a single principal" do
    get "/principals/1"
    assert_response :ok

    body = JSON.parse(response.body)
    assert_kind_of Hash, body
    assert_equal 1, body["id"]
    assert_equal "actor", body["category"]
    assert_equal "[Vito Corleone, Michael Corleone, Sonny Corleone]", body["characters"]
  end
end
