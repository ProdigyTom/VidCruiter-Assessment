require "rails_helper"

RSpec.describe "Principals", type: :request do
  describe "GET /principals" do
    it "returns 200 with an array of principals" do
      get "/principals"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body).to be_an(Array)
      expect(body.first).to include(
        "id" => 1,
        "title_id" => "ABC123",
        "name_id" => "XYZ789",
        "category" => "actor"
      )
    end
  end

  describe "GET /principals/:id" do
    it "returns 200 with a single principal" do
      get "/principals/1"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body).to be_a(Hash)
      expect(body).to include(
        "id" => 1,
        "title_id" => "ABC123",
        "name_id" => "XYZ789",
        "category" => "actor"
      )
    end
  end
end
