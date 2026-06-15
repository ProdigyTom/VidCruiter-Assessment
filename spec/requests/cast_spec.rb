require "rails_helper"

RSpec.describe "Cast API", type: :request do
  let!(:name)  { Name.create!(id: "nm_cspec_1", primary_name: "Spec Actor",
                              birth_year: 1980, death_year: nil,
                              primary_profession: '["actor","producer"]',
                              known_for_titles: "[]") }
  let!(:genre)          { Genre.create!(name: "CastSpecGenre_#{SecureRandom.hex(4)}") }
  let!(:acting_title)   { Title.create!(id: "tt_cspec_act", primary_title: "Acting Spec Movie",    start_year: 2015, runtime: 100) }
  let!(:directing_title){ Title.create!(id: "tt_cspec_dir", primary_title: "Directing Spec Movie", start_year: 2018, runtime: 90) }

  before do
    TitleGenre.create!(title: acting_title, genre: genre)
    Rating.create!(title: acting_title, average_rating: 7.5, number_of_votes: 150)
    Principal.create!(title: acting_title,   name: name, ordering: 1, category: "actor",    characters: '["Hero"]')
    Principal.create!(title: directing_title, name: name, ordering: 1, category: "director", characters: nil)
  end

  describe "GET /cast/:id" do
    context "with a valid id" do
      before { get "/cast/#{name.id}" }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      subject(:body) { JSON.parse(response.body) }

      it "includes id and name" do
        expect(body).to include("id" => "nm_cspec_1", "name" => "Spec Actor")
      end

      it "includes birth_year and death_year" do
        expect(body["birth_year"]).to eq(1980)
        expect(body["death_year"]).to be_nil
      end

      it "includes primary_professions as a parsed array" do
        expect(body["primary_professions"]).to eq([ "actor", "producer" ])
      end

      it "includes known_for as an array" do
        expect(body["known_for"]).to be_an(Array)
      end

      it "filmography contains only acting credits" do
        ids = body["filmography"].map { |t| t["id"] }
        expect(ids).to include("tt_cspec_act")
        expect(ids).not_to include("tt_cspec_dir")
      end

      it "filmography titles include the correct shape" do
        film = body["filmography"].find { |t| t["id"] == "tt_cspec_act" }
        expect(film).to include(
          "title" => "Acting Spec Movie",
          "year" => 2015,
          "runtime" => 100,
          "rating" => 7.5
        )
        expect(film["genres"]).to include(genre.name)
      end
    end

    context "with an unknown id" do
      before { get "/cast/nm_does_not_exist" }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
