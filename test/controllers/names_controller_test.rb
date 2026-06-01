require "test_helper"

class NamesControllerTest < ActionDispatch::IntegrationTest
  test "GET /names returns 200 with an array" do
    get "/names"
    assert_response :ok

    body = JSON.parse(response.body)
    assert_kind_of Array, body
    assert_equal "ABC123", body.first["id"]
    assert_equal "Matt Damon", body.first["primary_name"]
    assert_equal 1970, body.first["birth_year"]
  end

  test "GET /names/:id returns 200 with a single name" do
    get "/names/ABC123"
    assert_response :ok

    body = JSON.parse(response.body)
    assert_kind_of Hash, body
    assert_equal "ABC123", body["id"]
    assert_equal "Matt Damon", body["primary_name"]
    assert_nil body["death_year"]
  end
end
