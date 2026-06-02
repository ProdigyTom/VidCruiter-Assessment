require "test_helper"

class TitlesControllerTest < ActionDispatch::IntegrationTest
  def setup
    @genre = Genre.create!(name: "TestGenre_#{SecureRandom.hex(4)}")
    @title = Title.create!(id: "tt_ctrl_1", primary_title: "Filter Test Movie", start_year: 1999, runtime: 120)
    TitleGenre.create!(title: @title, genre: @genre)
    Rating.create!(title: @title, average_rating: 8.0, number_of_votes: 100)
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
    ids = JSON.parse(response.body).map { |t| t["id"] }
    assert_includes ids, "tt_ctrl_1"
  end

  test "GET /titles?runtime= returns titles with runtime >= value" do
    get "/titles", params: { runtime: 90 }
    assert_response :ok
    ids = JSON.parse(response.body).map { |t| t["id"] }
    assert_includes ids, "tt_ctrl_1"
  end

  test "GET /titles?runtime= excludes titles below the threshold" do
    get "/titles", params: { runtime: 999 }
    assert_response :ok
    ids = JSON.parse(response.body).map { |t| t["id"] }
    assert_not_includes ids, "tt_ctrl_1"
  end

  test "GET /titles?genre= returns titles in that genre" do
    get "/titles", params: { genre: @genre.name }
    assert_response :ok
    ids = JSON.parse(response.body).map { |t| t["id"] }
    assert_includes ids, "tt_ctrl_1"
  end

  test "GET /titles?rating= returns titles with average_rating >= value" do
    get "/titles", params: { rating: 7.0 }
    assert_response :ok
    ids = JSON.parse(response.body).map { |t| t["id"] }
    assert_includes ids, "tt_ctrl_1"
  end

  test "GET /titles?rating= excludes titles below the threshold" do
    get "/titles", params: { rating: 9.5 }
    assert_response :ok
    ids = JSON.parse(response.body).map { |t| t["id"] }
    assert_not_includes ids, "tt_ctrl_1"
  end

  # --- Index: stacked filters ---

  test "GET /titles with multiple filters returns only titles matching all" do
    get "/titles", params: { year: 1999, runtime: 90, genre: @genre.name, rating: 7.0 }
    assert_response :ok
    ids = JSON.parse(response.body).map { |t| t["id"] }
    assert_includes ids, "tt_ctrl_1"
  end

  # --- Index: response shape ---

  test "GET /titles returns the correct response shape" do
    get "/titles", params: { year: 1999 }
    assert_response :ok
    title = JSON.parse(response.body).find { |t| t["id"] == "tt_ctrl_1" }
    assert_not_nil title
    assert_equal "Filter Test Movie", title["title"]
    assert_equal 1999, title["year"]
    assert_equal 120, title["runtime"]
    assert_kind_of Array, title["genres"]
    assert_includes title["genres"], @genre.name
    assert_equal 8.0, title["rating"]
  end
end
