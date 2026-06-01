require "test_helper"

class CrewTest < ActiveSupport::TestCase
  def title
    @title ||= Title.new(id: "ABC123", primary_title: "Shawshank Redemption")
  end

  # --- Validations ---

  test "is valid with a title" do
    crew = Crew.new(title: title, directors: "Steven Spielberg")
    assert crew.valid?
  end

  test "is invalid without a title" do
    crew = Crew.new(directors: "Steven Spielberg")
    assert_not crew.valid?
    assert_includes crew.errors[:title], "must exist"
  end

  # --- Associations ---

  test "belongs to a title" do
    assert_equal :belongs_to, Crew.reflect_on_association(:title).macro
  end
end
