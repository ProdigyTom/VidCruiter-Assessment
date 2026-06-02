require "rails_helper"

RSpec.describe "Writers API", type: :request do
  let!(:name)  { Name.create!(id: "nm_wspec_1", primary_name: "Spec Writer",
                              birth_year: 1970, death_year: nil,
                              primary_profession: '["writer","director"]',
                              known_for_titles: "[]") }
  let!(:genre) { Genre.create!(name: "WriterSpecGenre_#{SecureRandom.hex(4)}") }
  let!(:title) { Title.create!(id: "tt_wspec_1", primary_title: "Writer Spec Movie", start_year: 2008, runtime: 95) }

  before do
    TitleGenre.create!(title: title, genre: genre)
    Rating.create!(title: title, average_rating: 7.2, number_of_votes: 100)
    Writer.create!(title: title, name: name)
  end

  describe "GET /writers/:id" do
    context "with a valid id" do
      before { get "/writers/#{name.id}" }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      subject(:body) { JSON.parse(response.body) }

      it "includes id and name" do
        expect(body).to include("id" => "nm_wspec_1", "name" => "Spec Writer")
      end

      it "includes birth_year and death_year" do
        expect(body["birth_year"]).to eq(1970)
        expect(body["death_year"]).to be_nil
      end

      it "includes primary_professions as a parsed array" do
        expect(body["primary_professions"]).to eq([ "writer", "director" ])
      end

      it "includes known_for as an array" do
        expect(body["known_for"]).to be_an(Array)
      end

      it "includes filmography with the writer's credited titles" do
        ids = body["filmography"].map { |t| t["id"] }
        expect(ids).to include("tt_wspec_1")
      end

      it "filmography titles include the correct shape" do
        film = body["filmography"].find { |t| t["id"] == "tt_wspec_1" }
        expect(film).to include(
          "title" => "Writer Spec Movie",
          "year" => 2008,
          "runtime" => 95,
          "rating" => 7.2
        )
        expect(film["genres"]).to include(genre.name)
      end
    end

    context "with an unknown id" do
      before { get "/writers/nm_does_not_exist" }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
