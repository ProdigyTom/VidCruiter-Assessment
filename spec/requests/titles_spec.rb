require "rails_helper"

RSpec.describe "Titles API", type: :request do
  let!(:genre)    { Genre.create!(name: "SpecGenre_#{SecureRandom.hex(4)}") }
  let!(:title)    { Title.create!(id: "tt_spec_1", primary_title: "Spec Movie", original_title: "Spec Movie", start_year: 2005, runtime: 110) }
  let!(:director) { Name.create!(id: "nm_spec_dir", primary_name: "Spec Director") }
  let!(:writer)   { Name.create!(id: "nm_spec_wri", primary_name: "Spec Writer") }
  let!(:actor)    { Name.create!(id: "nm_spec_act", primary_name: "Spec Actor") }
  let!(:editor)   { Name.create!(id: "nm_spec_edi", primary_name: "Spec Editor") }

  before do
    TitleGenre.create!(title: title, genre: genre)
    Rating.create!(title: title, average_rating: 8.5, number_of_votes: 200)
    Director.create!(title: title, name: director)
    Writer.create!(title: title, name: writer)
    Principal.create!(title: title, name: actor,  ordering: 1, category: "actor",  characters: '["Hero"]')
    Principal.create!(title: title, name: editor, ordering: 2, category: "editor", characters: nil)
  end

  # -------------------------------------------------------------------------
  describe "GET /titles" do
    context "with no filters" do
      before { get "/titles" }

      it "returns 400" do
        expect(response).to have_http_status(:bad_request)
      end

      it "returns an error message" do
        expect(JSON.parse(response.body)).to include("error")
      end
    end

    context "with a year filter" do
      before { get "/titles", params: { year: 2005 } }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "includes the matching title" do
        ids = JSON.parse(response.body)["titles"].map { |t| t["id"] }
        expect(ids).to include("tt_spec_1")
      end
    end

    context "with a runtime filter" do
      it "includes titles at or above the threshold" do
        get "/titles", params: { runtime: 90 }
        ids = JSON.parse(response.body)["titles"].map { |t| t["id"] }
        expect(ids).to include("tt_spec_1")
      end

      it "excludes titles below the threshold" do
        get "/titles", params: { runtime: 999 }
        ids = JSON.parse(response.body)["titles"].map { |t| t["id"] }
        expect(ids).not_to include("tt_spec_1")
      end
    end

    context "with a genre filter" do
      before { get "/titles", params: { genre: genre.name } }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "includes the matching title" do
        ids = JSON.parse(response.body)["titles"].map { |t| t["id"] }
        expect(ids).to include("tt_spec_1")
      end
    end

    context "with a rating filter" do
      it "includes titles at or above the threshold" do
        get "/titles", params: { rating: 7.0 }
        ids = JSON.parse(response.body)["titles"].map { |t| t["id"] }
        expect(ids).to include("tt_spec_1")
      end

      it "excludes titles below the threshold" do
        get "/titles", params: { rating: 9.9 }
        ids = JSON.parse(response.body)["titles"].map { |t| t["id"] }
        expect(ids).not_to include("tt_spec_1")
      end
    end

    context "with stacked filters" do
      before { get "/titles", params: { year: 2005, runtime: 90, genre: genre.name, rating: 7.0 } }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "includes titles matching all filters" do
        ids = JSON.parse(response.body)["titles"].map { |t| t["id"] }
        expect(ids).to include("tt_spec_1")
      end
    end

    context "pagination metadata" do
      before { get "/titles", params: { year: 2005 } }

      it "includes total_pages" do
        expect(JSON.parse(response.body)).to include("total_pages")
      end

      it "includes page" do
        expect(JSON.parse(response.body)["page"]).to eq(1)
      end

      it "includes total_result" do
        expect(JSON.parse(response.body)["total_result"]).to be >= 1
      end

      it "includes result_count matching the titles array length" do
        body = JSON.parse(response.body)
        expect(body["result_count"]).to eq(body["titles"].length)
      end
    end

    context "with an out-of-range page" do
      before { get "/titles", params: { year: 2005, page: 9999 } }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns an empty titles array" do
        expect(JSON.parse(response.body)["titles"]).to eq([])
      end
    end

    context "title response shape" do
      before { get "/titles", params: { year: 2005 } }

      subject(:result) { JSON.parse(response.body)["titles"].find { |t| t["id"] == "tt_spec_1" } }

      it "includes id" do
        expect(result["id"]).to eq("tt_spec_1")
      end

      it "includes title" do
        expect(result["title"]).to eq("Spec Movie")
      end

      it "includes year" do
        expect(result["year"]).to eq(2005)
      end

      it "includes runtime" do
        expect(result["runtime"]).to eq(110)
      end

      it "includes genres as an array" do
        expect(result["genres"]).to include(genre.name)
      end

      it "includes rating" do
        expect(result["rating"]).to eq(8.5)
      end
    end
  end

  # -------------------------------------------------------------------------
  describe "GET /titles/:id" do
    context "with a valid id" do
      before { get "/titles/tt_spec_1" }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      subject(:body) { JSON.parse(response.body) }

      it "includes id, title, original_title, year, runtime" do
        expect(body).to include(
          "id" => "tt_spec_1",
          "title" => "Spec Movie",
          "original_title" => "Spec Movie",
          "year" => 2005,
          "runtime" => 110
        )
      end

      it "includes genres" do
        expect(body["genres"]).to include(genre.name)
      end

      it "includes rating" do
        expect(body["rating"]).to eq(8.5)
      end

      it "includes directors with id and name" do
        expect(body["directors"]).to include({ "id" => "nm_spec_dir", "name" => "Spec Director" })
      end

      it "includes writers with id and name" do
        expect(body["writers"]).to include({ "id" => "nm_spec_wri", "name" => "Spec Writer" })
      end

      it "includes only actors and actresses in cast" do
        cast_ids = body["cast"].map { |c| c["id"] }
        expect(cast_ids).to include("nm_spec_act")
        expect(cast_ids).not_to include("nm_spec_edi")
      end

      it "includes role as a parsed array in cast" do
        actor_entry = body["cast"].find { |c| c["id"] == "nm_spec_act" }
        expect(actor_entry["role"]).to eq([ "Hero" ])
      end

      it "includes everyone in principals" do
        principal_ids = body["principals"].map { |p| p["id"] }
        expect(principal_ids).to include("nm_spec_act", "nm_spec_edi")
      end
    end

    context "with an unknown id" do
      before { get "/titles/tt_does_not_exist" }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # -------------------------------------------------------------------------
  describe "GET /titles/:id/writers" do
    context "with a valid title id" do
      before { get "/titles/tt_spec_1/writers" }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns an array of writers with id and name" do
        expect(JSON.parse(response.body)).to include({ "id" => "nm_spec_wri", "name" => "Spec Writer" })
      end
    end

    context "with an unknown title id" do
      before { get "/titles/tt_does_not_exist/writers" }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # -------------------------------------------------------------------------
  describe "GET /titles/:id/directors" do
    context "with a valid title id" do
      before { get "/titles/tt_spec_1/directors" }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "returns an array of directors with id and name" do
        expect(JSON.parse(response.body)).to include({ "id" => "nm_spec_dir", "name" => "Spec Director" })
      end
    end

    context "with an unknown title id" do
      before { get "/titles/tt_does_not_exist/directors" }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # -------------------------------------------------------------------------
  describe "GET /titles/:id/cast" do
    context "with a valid title id" do
      before { get "/titles/tt_spec_1/cast" }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "includes actors" do
        ids = JSON.parse(response.body).map { |p| p["id"] }
        expect(ids).to include("nm_spec_act")
      end

      it "excludes non-actors" do
        ids = JSON.parse(response.body).map { |p| p["id"] }
        expect(ids).not_to include("nm_spec_edi")
      end

      it "includes role as a parsed array" do
        entry = JSON.parse(response.body).find { |p| p["id"] == "nm_spec_act" }
        expect(entry["role"]).to eq([ "Hero" ])
      end
    end

    context "with an unknown title id" do
      before { get "/titles/tt_does_not_exist/cast" }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  # -------------------------------------------------------------------------
  describe "GET /titles/:id/principals" do
    context "with a valid title id" do
      before { get "/titles/tt_spec_1/principals" }

      it "returns 200" do
        expect(response).to have_http_status(:ok)
      end

      it "includes all credited people" do
        ids = JSON.parse(response.body).map { |p| p["id"] }
        expect(ids).to include("nm_spec_act", "nm_spec_edi")
      end
    end

    context "with an unknown title id" do
      before { get "/titles/tt_does_not_exist/principals" }

      it "returns 404" do
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
