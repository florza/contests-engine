require 'test_helper'

class ContestTest < ActiveSupport::TestCase
  test "is valid with required attributes" do
    c = Contest.create(
      user: users(:userOne),
      name: 'name',
      shortname: 'short name',
      description: 'description',
      contesttype: 'group',
      nbr_sets: 1,
      public: false
    )
    refute c.errors.any?
    assert c.valid?
  end

  test "must have a name" do
    c = Contest.create(
      user: users(:userOne),
      name: nil,
      shortname: 'short name',
      description: 'description',
      contesttype: 'group',
      nbr_sets: 1,
      public: false
    )
    assert c.errors[:name].any?
    refute c.valid?
  end
end
