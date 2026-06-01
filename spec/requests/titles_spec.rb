require "rails_helper"

RSpec.describe "Titles", type: :request do
  describe "GET /titles" do
    it "returns 200 with an array of titles" do
      get "/titles"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body).to be_an(Array)
      expect(body.first).to include(
        "id" => "ABC123",
        "primary_title" => "The Godfather",
        "start_year" => 1972,
        "genres" => "Action,Crime"
      )
    end
  end

  describe "GET /titles/:id" do
    it "returns 200 with a single title" do
      get "/titles/ABC123"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body).to be_a(Hash)
      expect(body).to include(
        "id" => "ABC123",
        "primary_title" => "The Godfather",
        "start_year" => 1972,
        "genres" => "Action,Crime"
      )
    end
  end
end
