require "rails_helper"

RSpec.describe "Names", type: :request do
  describe "GET /names" do
    it "returns 200 with an array of names" do
      get "/names"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body).to be_an(Array)
      expect(body.first).to include(
        "id" => "ABC123",
        "primary_name" => "Matt Damon",
        "birth_year" => 1970
      )
    end
  end

  describe "GET /names/:id" do
    it "returns 200 with a single name" do
      get "/names/ABC123"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)
      expect(body).to be_a(Hash)
      expect(body).to include(
        "id" => "ABC123",
        "primary_name" => "Matt Damon",
        "birth_year" => 1970
      )
    end
  end
end
