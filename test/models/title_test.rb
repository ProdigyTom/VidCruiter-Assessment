require "test_helper"

class TitleTest < ActiveSupport::TestCase
  # --- Validations ---

  test "is valid with a primary_title" do
    title = Title.new(id: "ABC123", primary_title: "Gone With the Wind")
    assert title.valid?
  end

  test "is valid with a nil start_year" do
    title = Title.new(id: "XYZ789", primary_title: "Toy Story", start_year: nil)
    assert title.valid?
  end

  test "is valid with an integer start_year" do
    title = Title.new(id: "ABC123", primary_title: "Happy Gilmore", start_year: 2020)
    assert title.valid?
  end

  test "is invalid without primary_title" do
    title = Title.new(id: "XYZ789")
    assert_not title.valid?
    assert_includes title.errors[:primary_title], "can't be blank"
  end

  test "is invalid with a non-integer start_year" do
    title = Title.new(id: "CBA321", primary_title: "Jurrasic Park", start_year: "not a year")
    assert_not title.valid?
    assert title.errors[:start_year].any?
  end

  test "saves successfully with valid attributes" do
    title = Title.new(id: "ZYX987", primary_title: "The Terminator", start_year: 1980)
    assert title.save
    assert title.persisted?
  end

  # --- Associations ---

  test "has one rating" do
    assert_equal :has_one, Title.reflect_on_association(:rating).macro
  end

  test "has many principals" do
    assert_equal :has_many, Title.reflect_on_association(:principals).macro
  end

  test "has many title_genres" do
    assert_equal :has_many, Title.reflect_on_association(:title_genres).macro
  end

  test "has many genres through title_genres" do
    reflection = Title.reflect_on_association(:genres)
    assert_equal :has_many, reflection.macro
    assert_equal :title_genres, reflection.options[:through]
  end

  test "has many directors" do
    assert_equal :has_many, Title.reflect_on_association(:directors).macro
  end

  test "has many writers" do
    assert_equal :has_many, Title.reflect_on_association(:writers).macro
  end
end
