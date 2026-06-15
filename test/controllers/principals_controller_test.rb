require "test_helper"

class PrincipalsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @name  = Name.create!(id: "nm_pri_1", primary_name: "Test Principal",
                          birth_year: 1975, death_year: nil,
                          primary_profession: '["actor","writer"]',
                          known_for_titles: "[]")
    @genre = Genre.create!(name: "TestPrincipalGenre_#{SecureRandom.hex(4)}")
    @title = Title.create!(id: "tt_pri_1", primary_title: "Principal Test Movie", start_year: 2016, runtime: 105)
    TitleGenre.create!(title: @title, genre: @genre)
    Rating.create!(title: @title, average_rating: 7.8, number_of_votes: 150)

    # Two credits on the same title — actor and writer
    Principal.create!(title: @title, name: @name, ordering: 1, category: "actor",  characters: '["Hero"]', job: nil)
    Principal.create!(title: @title, name: @name, ordering: 2, category: "writer", characters: nil,        job: "written by")

    # A second title with a single credit
    @title2 = Title.create!(id: "tt_pri_2", primary_title: "Another Movie", start_year: 2020, runtime: 95)
    Principal.create!(title: @title2, name: @name, ordering: 1, category: "actor", characters: '["Villain"]', job: nil)
  end

  test "GET /principals/:id returns 200 with principal detail" do
    get "/principals/#{@name.id}"
    assert_response :ok

    body = JSON.parse(response.body)
    assert_equal "nm_pri_1", body["id"]
    assert_equal "Test Principal", body["name"]
    assert_equal 1975, body["birth_year"]
    assert_nil body["death_year"]
    assert_equal [ "actor", "writer" ], body["primary_professions"]
    assert_kind_of Array, body["known_for"]
    assert_kind_of Array, body["filmography"]
  end

  test "GET /principals/:id filmography contains all credited titles" do
    get "/principals/#{@name.id}"
    ids = JSON.parse(response.body)["filmography"].map { |t| t["id"] }
    assert_includes ids, "tt_pri_1"
    assert_includes ids, "tt_pri_2"
  end

  test "GET /principals/:id filmography groups multiple credits on the same title" do
    get "/principals/#{@name.id}"
    film = JSON.parse(response.body)["filmography"].find { |t| t["id"] == "tt_pri_1" }
    assert_equal 2, film["credits"].length
    categories = film["credits"].map { |c| c["category"] }
    assert_includes categories, "actor"
    assert_includes categories, "writer"
  end

  test "GET /principals/:id credits have the correct shape" do
    get "/principals/#{@name.id}"
    film   = JSON.parse(response.body)["filmography"].find { |t| t["id"] == "tt_pri_1" }
    actor  = film["credits"].find { |c| c["category"] == "actor" }
    writer = film["credits"].find { |c| c["category"] == "writer" }

    assert_equal [ "Hero" ], actor["role"]
    assert_nil actor["job"]
    assert_nil writer["role"]
    assert_equal "written by", writer["job"]
  end

  test "GET /principals/:id filmography titles have the correct shape" do
    get "/principals/#{@name.id}"
    film = JSON.parse(response.body)["filmography"].find { |t| t["id"] == "tt_pri_1" }
    assert_equal "Principal Test Movie", film["title"]
    assert_equal 2016, film["year"]
    assert_equal 105, film["runtime"]
    assert_includes film["genres"], @genre.name
    assert_equal 7.8, film["rating"]
  end

  test "GET /principals/:id returns 404 for unknown id" do
    get "/principals/nm_does_not_exist"
    assert_response :not_found
  end
end
