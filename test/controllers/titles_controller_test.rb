require "test_helper"

class TitlesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @genre    = Genre.create!(name: "TestGenre_#{SecureRandom.hex(4)}")
    @title    = Title.create!(id: "tt_ctrl_1", primary_title: "Filter Test Movie", start_year: 1999, runtime: 120)
    @director = Name.create!(id: "nm_ctrl_dir", primary_name: "Test Director")
    @writer   = Name.create!(id: "nm_ctrl_wri", primary_name: "Test Writer")
    @actor    = Name.create!(id: "nm_ctrl_act", primary_name: "Test Actor")
    @editor   = Name.create!(id: "nm_ctrl_edi", primary_name: "Test Editor")
    TitleGenre.create!(title: @title, genre: @genre)
    Rating.create!(title: @title, average_rating: 8.0, number_of_votes: 100)
    Director.create!(title: @title, name: @director)
    Writer.create!(title: @title, name: @writer)
    Principal.create!(title: @title, name: @actor,  ordering: 1, category: "actor",  characters: '["Hero"]')
    Principal.create!(title: @title, name: @editor, ordering: 2, category: "editor", characters: nil)
  end

  # --- Index: filter enforcement ---

  test "GET /titles with no filters returns 400" do
    get "/titles"
    assert_response :bad_request
    body = JSON.parse(response.body)
    assert body["error"].present?
  end

  # --- Index: individual filters ---

  test "GET /titles?year= returns matching titles" do
    get "/titles", params: { year: 1999 }
    assert_response :ok
    ids = JSON.parse(response.body)["titles"].map { |t| t["id"] }
    assert_includes ids, "tt_ctrl_1"
  end

  test "GET /titles?runtime= returns titles with runtime >= value" do
    get "/titles", params: { runtime: 90 }
    assert_response :ok
    ids = JSON.parse(response.body)["titles"].map { |t| t["id"] }
    assert_includes ids, "tt_ctrl_1"
  end

  test "GET /titles?runtime= excludes titles below the threshold" do
    get "/titles", params: { runtime: 999 }
    assert_response :ok
    ids = JSON.parse(response.body)["titles"].map { |t| t["id"] }
    assert_not_includes ids, "tt_ctrl_1"
  end

  test "GET /titles?genre= returns titles in that genre" do
    get "/titles", params: { genre: @genre.name }
    assert_response :ok
    ids = JSON.parse(response.body)["titles"].map { |t| t["id"] }
    assert_includes ids, "tt_ctrl_1"
  end

  test "GET /titles?rating= returns titles with average_rating >= value" do
    get "/titles", params: { rating: 7.0 }
    assert_response :ok
    ids = JSON.parse(response.body)["titles"].map { |t| t["id"] }
    assert_includes ids, "tt_ctrl_1"
  end

  test "GET /titles?rating= excludes titles below the threshold" do
    get "/titles", params: { rating: 9.5 }
    assert_response :ok
    ids = JSON.parse(response.body)["titles"].map { |t| t["id"] }
    assert_not_includes ids, "tt_ctrl_1"
  end

  # --- Index: stacked filters ---

  test "GET /titles with multiple filters returns only titles matching all" do
    get "/titles", params: { year: 1999, runtime: 90, genre: @genre.name, rating: 7.0 }
    assert_response :ok
    ids = JSON.parse(response.body)["titles"].map { |t| t["id"] }
    assert_includes ids, "tt_ctrl_1"
  end

  # --- Index: response shape and pagination metadata ---

  test "GET /titles returns the correct response shape" do
    get "/titles", params: { year: 1999 }
    assert_response :ok

    body = JSON.parse(response.body)
    assert body.key?("total_pages")
    assert body.key?("page")
    assert body.key?("total_result")
    assert body.key?("result_count")
    assert body.key?("titles")
    assert_kind_of Array, body["titles"]

    title = body["titles"].find { |t| t["id"] == "tt_ctrl_1" }
    assert_not_nil title
    assert_equal "Filter Test Movie", title["title"]
    assert_equal 1999, title["year"]
    assert_equal 120, title["runtime"]
    assert_kind_of Array, title["genres"]
    assert_includes title["genres"], @genre.name
    assert_equal 8.0, title["rating"]
  end

  test "GET /titles page defaults to 1 when not provided" do
    get "/titles", params: { year: 1999 }
    assert_response :ok
    assert_equal 1, JSON.parse(response.body)["page"]
  end

  test "GET /titles returns correct pagination metadata" do
    get "/titles", params: { year: 1999, page: 1 }
    assert_response :ok

    body = JSON.parse(response.body)
    assert_equal 1, body["page"]
    assert_operator body["total_result"], :>=, 1
    assert_operator body["total_pages"], :>=, 1
    assert_operator body["result_count"], :<=, 50
    assert_equal body["result_count"], body["titles"].length
  end

  test "GET /titles out-of-range page returns empty titles with correct metadata" do
    get "/titles", params: { year: 1999, page: 9999 }
    assert_response :ok

    body = JSON.parse(response.body)
    assert_equal 9999, body["page"]
    assert_equal 0, body["result_count"]
    assert_equal [], body["titles"]
  end

  test "GET /titles result_count matches titles array length" do
    get "/titles", params: { genre: @genre.name }
    assert_response :ok
    body = JSON.parse(response.body)
    assert_equal body["result_count"], body["titles"].length
  end

  # --- Show ---

  test "GET /titles/:id returns 200 with full title detail" do
    get "/titles/#{@title.id}"
    assert_response :ok

    body = JSON.parse(response.body)
    assert_equal "tt_ctrl_1", body["id"]
    assert_equal "Filter Test Movie", body["title"]
    assert_equal 1999, body["year"]
    assert_equal 120, body["runtime"]
    assert_includes body["genres"], @genre.name
    assert_equal 8.0, body["rating"]
    assert_equal "nm_ctrl_dir", body["directors"].first["id"]
    assert_equal "nm_ctrl_wri", body["writers"].first["id"]
    assert_kind_of Array, body["cast"]
    assert_kind_of Array, body["principals"]
  end

  test "GET /titles/:id cast contains only actors and actresses" do
    get "/titles/#{@title.id}"
    assert_response :ok
    body = JSON.parse(response.body)
    cast_ids = body["cast"].map { |c| c["id"] }
    assert_includes cast_ids, "nm_ctrl_act"
    assert_not_includes cast_ids, "nm_ctrl_edi"
    assert_equal [ "Hero" ], body["cast"].first["role"]
  end

  test "GET /titles/:id principals contains everyone" do
    get "/titles/#{@title.id}"
    assert_response :ok
    principal_ids = JSON.parse(response.body)["principals"].map { |p| p["id"] }
    assert_includes principal_ids, "nm_ctrl_act"
    assert_includes principal_ids, "nm_ctrl_edi"
  end

  test "GET /titles/:id returns 404 for unknown id" do
    get "/titles/tt_does_not_exist"
    assert_response :not_found
  end

  # --- Nested actions ---

  test "GET /titles/:id/writers returns writers for the title" do
    get "/titles/#{@title.id}/writers"
    assert_response :ok
    body = JSON.parse(response.body)
    assert_kind_of Array, body
    assert_equal "nm_ctrl_wri", body.first["id"]
    assert_equal "Test Writer", body.first["name"]
  end

  test "GET /titles/:id/directors returns directors for the title" do
    get "/titles/#{@title.id}/directors"
    assert_response :ok
    body = JSON.parse(response.body)
    assert_kind_of Array, body
    assert_equal "nm_ctrl_dir", body.first["id"]
    assert_equal "Test Director", body.first["name"]
  end

  test "GET /titles/:id/cast returns only actors and actresses" do
    get "/titles/#{@title.id}/cast"
    assert_response :ok
    body = JSON.parse(response.body)
    ids = body.map { |p| p["id"] }
    assert_includes ids, "nm_ctrl_act"
    assert_not_includes ids, "nm_ctrl_edi"
    assert_equal [ "Hero" ], body.first["role"]
  end

  test "GET /titles/:id/principals returns everyone credited" do
    get "/titles/#{@title.id}/principals"
    assert_response :ok
    ids = JSON.parse(response.body).map { |p| p["id"] }
    assert_includes ids, "nm_ctrl_act"
    assert_includes ids, "nm_ctrl_edi"
  end

  test "GET /titles/:id/writers returns 404 for unknown title" do
    get "/titles/tt_does_not_exist/writers"
    assert_response :not_found
  end
end
