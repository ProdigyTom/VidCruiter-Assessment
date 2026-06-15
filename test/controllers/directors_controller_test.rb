require "test_helper"

class DirectorsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @name  = Name.create!(id: "nm_dir_1", primary_name: "Test Director",
                          birth_year: 1965, death_year: nil,
                          primary_profession: '["director","producer"]',
                          known_for_titles: "[]")
    @title = Title.create!(id: "tt_dir_1", primary_title: "Director Test Movie", start_year: 2015, runtime: 115)
    @genre = Genre.create!(name: "TestDirectorGenre_#{SecureRandom.hex(4)}")
    TitleGenre.create!(title: @title, genre: @genre)
    Rating.create!(title: @title, average_rating: 8.2, number_of_votes: 200)
    Director.create!(title: @title, name: @name)
  end

  test "GET /directors/:id returns 200 with director detail" do
    get "/directors/#{@name.id}"
    assert_response :ok

    body = JSON.parse(response.body)
    assert_equal "nm_dir_1", body["id"]
    assert_equal "Test Director", body["name"]
    assert_equal 1965, body["birth_year"]
    assert_nil body["death_year"]
    assert_equal [ "director", "producer" ], body["primary_professions"]
    assert_kind_of Array, body["known_for"]
    assert_kind_of Array, body["filmography"]
  end

  test "GET /directors/:id filmography contains titles the director is credited on" do
    get "/directors/#{@name.id}"
    assert_response :ok

    ids = JSON.parse(response.body)["filmography"].map { |t| t["id"] }
    assert_includes ids, "tt_dir_1"
  end

  test "GET /directors/:id filmography titles have the correct shape" do
    get "/directors/#{@name.id}"
    film = JSON.parse(response.body)["filmography"].first
    assert_equal "tt_dir_1", film["id"]
    assert_equal "Director Test Movie", film["title"]
    assert_equal 2015, film["year"]
    assert_equal 115, film["runtime"]
    assert_includes film["genres"], @genre.name
    assert_equal 8.2, film["rating"]
  end

  test "GET /directors/:id returns 404 for unknown id" do
    get "/directors/nm_does_not_exist"
    assert_response :not_found
  end
end
