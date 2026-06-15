require "test_helper"

class PrincipalTest < ActiveSupport::TestCase
  def title
    @title ||= Title.new(id: "XYZ789", primary_title: "Bill and Ted's Excellent Adventure")
  end

  # Called name_entity to avoid conflicting with ActiveSupport::TestCase#name, which the test runner uses to identify tests.
  def name_entity
    @name_entity ||= Name.new(id: "CBA321", primary_name: "Keanu Reeves")
  end

  # --- Validations ---

  test "is valid with a title and name" do
    principal = Principal.new(title: title, name: name_entity, ordering: 1, category: "actor")
    assert principal.valid?
  end

  test "is invalid without a title" do
    principal = Principal.new(name: name_entity, ordering: 1, category: "actor")
    assert_not principal.valid?
    assert_includes principal.errors[:title], "must exist"
  end

  test "is invalid without a name" do
    principal = Principal.new(title: title, ordering: 1, category: "actor")
    assert_not principal.valid?
    assert_includes principal.errors[:name], "must exist"
  end

  # --- Associations ---

  test "belongs to a title" do
    assert_equal :belongs_to, Principal.reflect_on_association(:title).macro
  end

  test "belongs to a name" do
    assert_equal :belongs_to, Principal.reflect_on_association(:name).macro
  end
end
