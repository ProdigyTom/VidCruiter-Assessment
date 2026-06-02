require "test_helper"

class NameTest < ActiveSupport::TestCase
  # --- Persistence ---

  test "saves successfully with valid attributes" do
    name = Name.new(
      id: "ABC123",
      primary_name: "Julia Roberts",
      birth_year: 1967,
      primary_profession: "actor"
    )
    assert name.save
    assert name.persisted?
  end

  # --- Associations ---

  test "has many principals" do
    assert_equal :has_many, Name.reflect_on_association(:principals).macro
  end

  test "principals association uses name_id as foreign key" do
    reflection = Name.reflect_on_association(:principals)
    assert_equal "name_id", reflection.foreign_key.to_s
  end

  test "has many directors" do
    assert_equal :has_many, Name.reflect_on_association(:directors).macro
  end

  test "has many writers" do
    assert_equal :has_many, Name.reflect_on_association(:writers).macro
  end

  test "directors association uses name_id as foreign key" do
    reflection = Name.reflect_on_association(:directors)
    assert_equal "name_id", reflection.foreign_key.to_s
  end

  test "writers association uses name_id as foreign key" do
    reflection = Name.reflect_on_association(:writers)
    assert_equal "name_id", reflection.foreign_key.to_s
  end
end
