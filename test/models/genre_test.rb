require "test_helper"

class GenreTest < ActiveSupport::TestCase
  # --- Validations ---

  test "is valid with a name" do
    genre = Genre.new(name: "Drama")
    assert genre.valid?
  end

  test "is invalid without a name" do
    genre = Genre.new
    assert_not genre.valid?
    assert_includes genre.errors[:name], "can't be blank"
  end

  test "is invalid with a duplicate name" do
    Genre.create!(name: "Action")
    duplicate = Genre.new(name: "Action")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "saves successfully with a unique name" do
    genre = Genre.new(name: "Thriller")
    assert genre.save
    assert genre.persisted?
  end

  # --- Associations ---

  test "has many title_genres" do
    assert_equal :has_many, Genre.reflect_on_association(:title_genres).macro
  end

  test "has many titles through title_genres" do
    reflection = Genre.reflect_on_association(:titles)
    assert_equal :has_many, reflection.macro
    assert_equal :title_genres, reflection.options[:through]
  end
end
