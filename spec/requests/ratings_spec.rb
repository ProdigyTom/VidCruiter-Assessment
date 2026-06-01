require "rails_helper"

RSpec.describe "Ratings", type: :request do
  describe "GET /ratings" do
    it "returns 200 with an array of ratings" do
      get "/ratings"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body).to be_an(Array)
      expect(body.first).to include(
        "id" => 1,
        "title_id" => "ABC123",
        "average_rating" => 6.5,
        "number_of_votes" => 194
      )
    end
  end

  describe "GET /ratings/:id" do
    it "returns 200 with a single rating" do
      get "/ratings/1"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body).to be_a(Hash)
      expect(body).to include(
        "id" => 1,
        "title_id" => "ABC123",
        "average_rating" => 6.5,
        "number_of_votes" => 194
      )
    end
  end
end
