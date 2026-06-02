require "test_helper"

class CastControllerTest < ActionDispatch::IntegrationTest
  def setup
    @name  = Name.create!(id: "nm_cast_1", primary_name: "Test Actor",
                          birth_year: 1980, death_year: nil,
                          primary_profession: '["actor","producer"]',
                          known_for_titles: "[]")
    @genre = Genre.create!(name: "TestCastGenre_#{SecureRandom.hex(4)}")

    @acting_title = Title.create!(id: "tt_cast_act", primary_title: "Acting Movie", start_year: 2012, runtime: 90)
    TitleGenre.create!(title: @acting_title, genre: @genre)
    Rating.create!(title: @acting_title, average_rating: 7.0, number_of_votes: 80)
    Principal.create!(title: @acting_title, name: @name, ordering: 1, category: "actor", characters: '["Hero"]')

    @non_acting_title = Title.create!(id: "tt_cast_dir", primary_title: "Directing Movie", start_year: 2018, runtime: 110)
    Principal.create!(title: @non_acting_title, name: @name, ordering: 1, category: "director", characters: nil)
  end

  test "GET /cast/:id returns 200 with cast member detail" do
    get "/cast/#{@name.id}"
    assert_response :ok

    body = JSON.parse(response.body)
    assert_equal "nm_cast_1", body["id"]
    assert_equal "Test Actor", body["name"]
    assert_equal 1980, body["birth_year"]
    assert_nil body["death_year"]
    assert_equal [ "actor", "producer" ], body["primary_professions"]
    assert_kind_of Array, body["known_for"]
    assert_kind_of Array, body["filmography"]
  end

  test "GET /cast/:id filmography contains only acting credits" do
    get "/cast/#{@name.id}"
    assert_response :ok

    ids = JSON.parse(response.body)["filmography"].map { |t| t["id"] }
    assert_includes ids, "tt_cast_act"
    assert_not_includes ids, "tt_cast_dir"
  end

  test "GET /cast/:id filmography titles have the correct shape" do
    get "/cast/#{@name.id}"
    film = JSON.parse(response.body)["filmography"].find { |t| t["id"] == "tt_cast_act" }
    assert_equal "Acting Movie", film["title"]
    assert_equal 2012, film["year"]
    assert_equal 90, film["runtime"]
    assert_includes film["genres"], @genre.name
    assert_equal 7.0, film["rating"]
  end

  test "GET /cast/:id returns 404 for unknown id" do
    get "/cast/nm_does_not_exist"
    assert_response :not_found
  end
end
