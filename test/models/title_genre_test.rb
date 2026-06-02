require "test_helper"

class TitleGenreTest < ActiveSupport::TestCase
  def title
    @title ||= Title.new(id: "tt_test_1", primary_title: "Test Movie")
  end

  def genre
    @genre ||= Genre.new(name: "Drama")
  end

  # --- Validations ---

  test "is valid with a title and genre" do
    title_genre = TitleGenre.new(title: title, genre: genre)
    assert title_genre.valid?
  end

  test "is invalid without a title" do
    title_genre = TitleGenre.new(genre: genre)
    assert_not title_genre.valid?
    assert_includes title_genre.errors[:title], "must exist"
  end

  test "is invalid without a genre" do
    title_genre = TitleGenre.new(title: title)
    assert_not title_genre.valid?
    assert_includes title_genre.errors[:genre], "must exist"
  end

  # --- Associations ---

  test "belongs to a title" do
    assert_equal :belongs_to, TitleGenre.reflect_on_association(:title).macro
  end

  test "belongs to a genre" do
    assert_equal :belongs_to, TitleGenre.reflect_on_association(:genre).macro
  end
end
