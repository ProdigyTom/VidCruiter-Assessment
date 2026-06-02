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

  # --- Scopes ---

  test "by_year returns titles matching the given year" do
    title = Title.create!(id: "tt_scope_year", primary_title: "Scope Year Test", start_year: 1955)
    assert_includes Title.by_year(1955).map(&:id), "tt_scope_year"
    assert_not_includes Title.by_year(1956).map(&:id), "tt_scope_year"
  end

  test "by_runtime returns titles with runtime >= the given value" do
    short = Title.create!(id: "tt_scope_short", primary_title: "Short Film", runtime: 45)
    long  = Title.create!(id: "tt_scope_long",  primary_title: "Long Film",  runtime: 180)
    results = Title.by_runtime(90).map(&:id)
    assert_not_includes results, "tt_scope_short"
    assert_includes results, "tt_scope_long"
  end

  test "by_genre returns titles belonging to the given genre" do
    title = Title.create!(id: "tt_scope_genre", primary_title: "Scope Genre Test")
    genre = Genre.create!(name: "TestGenre_#{SecureRandom.hex(4)}")
    TitleGenre.create!(title: title, genre: genre)
    assert_includes Title.by_genre(genre.name).map(&:id), "tt_scope_genre"
  end

  test "by_rating returns titles with average_rating >= the given value" do
    low  = Title.create!(id: "tt_scope_low_rating",  primary_title: "Low Rated")
    high = Title.create!(id: "tt_scope_high_rating", primary_title: "High Rated")
    Rating.create!(title: low,  average_rating: 4.0, number_of_votes: 10)
    Rating.create!(title: high, average_rating: 8.5, number_of_votes: 10)
    results = Title.by_rating(7.0).map(&:id)
    assert_not_includes results, "tt_scope_low_rating"
    assert_includes results, "tt_scope_high_rating"
  end

  test "scopes are chainable" do
    title = Title.create!(id: "tt_scope_chain", primary_title: "Chain Test", start_year: 1966, runtime: 120)
    genre = Genre.create!(name: "TestChain_#{SecureRandom.hex(4)}")
    TitleGenre.create!(title: title, genre: genre)
    Rating.create!(title: title, average_rating: 9.0, number_of_votes: 10)
    results = Title.by_year(1966).by_runtime(90).by_genre(genre.name).by_rating(8.0).map(&:id)
    assert_includes results, "tt_scope_chain"
  end
end
