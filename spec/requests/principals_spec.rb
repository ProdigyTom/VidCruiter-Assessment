require "rails_helper"

RSpec.describe "Principals API", type: :request do
  let!(:name)  { Name.create!(id: "nm_pspec_1", primary_name: "Spec Principal",
                              birth_year: 1975, death_year: nil,
                              primary_profession: '["actor","writer"]',
                              known_for_titles: "[]") }
  let!(:genre) { Genre.create!(name: "PrincipalSpecGenre_#{SecureRandom.hex(4)}") }
  let!(:title) { Title.create!(id: "tt_pspec_1", primary_title: "Principal Spec Movie", start_year: 2010, runtime: 105) }
  let!(:title2){ Title.create!(id: "tt_pspec_2", primary_title: "Another Spec Movie",   start_year: 2020, runtime: 88) }

  before do
    TitleGenre.create!(title: title, genre: genre)
    Rating.create!(title: title, average_rating: 7.9, number_of_votes: 120)
    # Two credits on title — actor and writer
    Principal.create!(title: title, name: name, ordering: 1, category: "actor",  characters: '["Hero"]',  job: nil)
    Principal.create!(title: title, name: name, ordering: 2, category: "writer", characters: nil,          job: "written by")
    # One credit on title2
    Principal.create!(title: title2, name: name, ordering: 1, category: "actor", characters: '["Villain"]', job: nil)
  end

  describe "GET /principals/:id" do
    context "with a valid id" do
      before { get "/principals/#{name.id}" }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      subject(:body) { JSON.parse(response.body) }

      it "includes id and name" do
        expect(body).to include("id" => "nm_pspec_1", "name" => "Spec Principal")
      end

      it "includes birth_year and death_year" do
        expect(body["birth_year"]).to eq(1975)
        expect(body["death_year"]).to be_nil
      end

      it "includes primary_professions as a parsed array" do
        expect(body["primary_professions"]).to eq([ "actor", "writer" ])
      end

      it "includes known_for as an array" do
        expect(body["known_for"]).to be_an(Array)
      end

      it "filmography contains all credited titles" do
        ids = body["filmography"].map { |t| t["id"] }
        expect(ids).to include("tt_pspec_1", "tt_pspec_2")
      end

      it "filmography groups multiple credits on the same title" do
        film = body["filmography"].find { |t| t["id"] == "tt_pspec_1" }
        expect(film["credits"].length).to eq(2)
      end

      it "credits include category and job" do
        film   = body["filmography"].find { |t| t["id"] == "tt_pspec_1" }
        actor  = film["credits"].find { |c| c["category"] == "actor" }
        writer = film["credits"].find { |c| c["category"] == "writer" }
        expect(actor["role"]).to eq([ "Hero" ])
        expect(actor["job"]).to be_nil
        expect(writer["role"]).to be_nil
        expect(writer["job"]).to eq("written by")
      end

      it "filmography titles include the correct shape" do
        film = body["filmography"].find { |t| t["id"] == "tt_pspec_1" }
        expect(film).to include("title" => "Principal Spec Movie", "year" => 2010, "runtime" => 105, "rating" => 7.9)
        expect(film["genres"]).to include(genre.name)
      end
    end

    context "with an unknown id" do
      before { get "/principals/nm_does_not_exist" }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
