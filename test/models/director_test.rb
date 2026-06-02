require "test_helper"

class DirectorTest < ActiveSupport::TestCase
  def title
    @title ||= Title.new(id: "tt_test_1", primary_title: "Test Movie")
  end

  # Called name_entity to avoid conflicting with ActiveSupport::TestCase#name, which the test runner uses to identify tests.
  def name_entity
    @name_entity ||= Name.new(id: "nm_test_1", primary_name: "Test Director")
  end

  # --- Validations ---

  test "is valid with a title and name" do
    director = Director.new(title: title, name: name_entity)
    assert director.valid?
  end

  test "is invalid without a title" do
    director = Director.new(name: name_entity)
    assert_not director.valid?
    assert_includes director.errors[:title], "must exist"
  end

  test "is invalid without a name" do
    director = Director.new(title: title)
    assert_not director.valid?
    assert_includes director.errors[:name], "must exist"
  end

  # --- Associations ---

  test "belongs to a title" do
    assert_equal :belongs_to, Director.reflect_on_association(:title).macro
  end

  test "belongs to a name" do
    assert_equal :belongs_to, Director.reflect_on_association(:name).macro
  end
end
