require "test_helper"

class RatingTest < ActiveSupport::TestCase
  def title
    @title ||= Title.new(id: "ABC123", primary_title: "The Princess Bride")
  end

  # --- Validations ---

  test "is valid with all required attributes" do
    rating = Rating.new(title: title, average_rating: 7.5, number_of_votes: 1000)
    assert rating.valid?
  end

  test "is invalid without a title" do
    rating = Rating.new(average_rating: 7.5, number_of_votes: 1000)
    assert_not rating.valid?
    assert_includes rating.errors[:title], "must exist"
  end

  test "is invalid without average_rating" do
    rating = Rating.new(title: title, number_of_votes: 100)
    assert_not rating.valid?
    assert_includes rating.errors[:average_rating], "can't be blank"
  end

  test "is invalid when average_rating is below 0" do
    rating = Rating.new(title: title, average_rating: -1, number_of_votes: 100)
    assert_not rating.valid?
    assert_includes rating.errors[:average_rating], "must be greater than or equal to 0"
  end

  test "is invalid when average_rating exceeds 10" do
    rating = Rating.new(title: title, average_rating: 10.1, number_of_votes: 100)
    assert_not rating.valid?
    assert_includes rating.errors[:average_rating], "must be less than or equal to 10"
  end

  test "is invalid without number_of_votes" do
    rating = Rating.new(title: title, average_rating: 7.5)
    assert_not rating.valid?
    assert_includes rating.errors[:number_of_votes], "can't be blank"
  end

  test "is invalid when number_of_votes is not an integer" do
    rating = Rating.new(title: title, average_rating: 7.5, number_of_votes: 1.5)
    assert_not rating.valid?
    assert_includes rating.errors[:number_of_votes], "must be an integer"
  end

  test "is invalid when number_of_votes is negative" do
    rating = Rating.new(title: title, average_rating: 7.5, number_of_votes: -1)
    assert_not rating.valid?
    assert_includes rating.errors[:number_of_votes], "must be greater than or equal to 0"
  end

  test "is valid at average_rating boundary of 0" do
    rating = Rating.new(title: title, average_rating: 0, number_of_votes: 0)
    assert rating.valid?
  end

  test "is valid at average_rating boundary of 10" do
    rating = Rating.new(title: title, average_rating: 10, number_of_votes: 0)
    assert rating.valid?
  end

  # --- Associations ---

  test "belongs to a title" do
    assert_equal :belongs_to, Rating.reflect_on_association(:title).macro
  end
end
