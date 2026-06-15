require "test_helper"

class WritersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @name  = Name.create!(id: "nm_wri_1", primary_name: "Test Writer",
                          birth_year: 1970, death_year: nil,
                          primary_profession: '["writer","director"]',
                          known_for_titles: "[]")
    @title = Title.create!(id: "tt_wri_1", primary_title: "Writer Test Movie", start_year: 2010, runtime: 100)
    @genre = Genre.create!(name: "TestWriterGenre_#{SecureRandom.hex(4)}")
    TitleGenre.create!(title: @title, genre: @genre)
    Rating.create!(title: @title, average_rating: 7.5, number_of_votes: 50)
    Writer.create!(title: @title, name: @name)
  end

  test "GET /writers/:id returns 200 with writer detail" do
    get "/writers/#{@name.id}"
    assert_response :ok

    body = JSON.parse(response.body)
    assert_equal "nm_wri_1", body["id"]
    assert_equal "Test Writer", body["name"]
    assert_equal 1970, body["birth_year"]
    assert_nil body["death_year"]
    assert_equal [ "writer", "director" ], body["primary_professions"]
    assert_kind_of Array, body["known_for"]
    assert_kind_of Array, body["filmography"]
  end

  test "GET /writers/:id filmography contains titles the writer is credited on" do
    get "/writers/#{@name.id}"
    assert_response :ok

    filmography = JSON.parse(response.body)["filmography"]
    ids = filmography.map { |t| t["id"] }
    assert_includes ids, "tt_wri_1"
  end

  test "GET /writers/:id filmography titles have the correct shape" do
    get "/writers/#{@name.id}"
    film = JSON.parse(response.body)["filmography"].first
    assert_equal "tt_wri_1", film["id"]
    assert_equal "Writer Test Movie", film["title"]
    assert_equal 2010, film["year"]
    assert_equal 100, film["runtime"]
    assert_includes film["genres"], @genre.name
    assert_equal 7.5, film["rating"]
  end

  test "GET /writers/:id returns 404 for unknown id" do
    get "/writers/nm_does_not_exist"
    assert_response :not_found
  end
end
