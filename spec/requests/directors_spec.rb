require "rails_helper"

RSpec.describe "Directors API", type: :request do
  let!(:name)  { Name.create!(id: "nm_dspec_1", primary_name: "Spec Director",
                              birth_year: 1965, death_year: nil,
                              primary_profession: '["director","producer"]',
                              known_for_titles: "[]") }
  let!(:genre) { Genre.create!(name: "DirectorSpecGenre_#{SecureRandom.hex(4)}") }
  let!(:title) { Title.create!(id: "tt_dspec_1", primary_title: "Director Spec Movie", start_year: 2012, runtime: 120) }

  before do
    TitleGenre.create!(title: title, genre: genre)
    Rating.create!(title: title, average_rating: 8.1, number_of_votes: 300)
    Director.create!(title: title, name: name)
  end

  describe "GET /directors/:id" do
    context "with a valid id" do
      before { get "/directors/#{name.id}" }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      subject(:body) { JSON.parse(response.body) }

      it "includes id and name" do
        expect(body).to include("id" => "nm_dspec_1", "name" => "Spec Director")
      end

      it "includes birth_year and death_year" do
        expect(body["birth_year"]).to eq(1965)
        expect(body["death_year"]).to be_nil
      end

      it "includes primary_professions as a parsed array" do
        expect(body["primary_professions"]).to eq([ "director", "producer" ])
      end

      it "includes known_for as an array" do
        expect(body["known_for"]).to be_an(Array)
      end

      it "includes filmography with the director's credited titles" do
        ids = body["filmography"].map { |t| t["id"] }
        expect(ids).to include("tt_dspec_1")
      end

      it "filmography titles include the correct shape" do
        film = body["filmography"].find { |t| t["id"] == "tt_dspec_1" }
        expect(film).to include(
          "title" => "Director Spec Movie",
          "year" => 2012,
          "runtime" => 120,
          "rating" => 8.1
        )
        expect(film["genres"]).to include(genre.name)
      end
    end

    context "with an unknown id" do
      before { get "/directors/nm_does_not_exist" }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
