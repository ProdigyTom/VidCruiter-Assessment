require "rails_helper"

RSpec.describe "Crews", type: :request do
  describe "GET /crews" do
    it "returns 200 with an array of crew records" do
      get "/crews"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body).to be_an(Array)
      expect(body.first).to include(
        "id" => 1,
        "title_id" => "ABC123",
        "directors" => "Ron Howard"
      )
    end
  end

  describe "GET /crews/:id" do
    it "returns 200 with a single crew record" do
      get "/crews/1"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body).to be_a(Hash)
      expect(body).to include(
        "id" => 1,
        "title_id" => "ABC123",
        "directors" => "Ron Howard"
      )
    end
  end
end
