require 'test_helper'

class ContestTest < ActiveSupport::TestCase

  def setup
    @contest = Contest.new(
      user: users(:userOne),
      name: 'name',
      shortname: 'short name',
      description: 'description',
      contesttype: 'group',
      nbr_sets: 1,
      public: true
    )
  end

  test "sample user is valid" do
    assert @contest.valid?
  end

  test "required attributes must be set" do
    [:user_id, :name, :shortname, :description,
            :contesttype, :nbr_sets, :public].each do |attr|
      contest2 = @contest.dup
      contest2[attr] = nil
      assert_not contest2.valid?, "Empty #{attr.to_s} must be invalid"
    end
  end

  test "name must be unique within user" do
    duplicate_contest = @contest.dup
    duplicate_contest.name = @contest.name.upcase
    duplicate_contest.shortname = 'another short name'
    @contest.save
    assert_not duplicate_contest.valid?
  end

  test "name may be duplicate with other user" do
    duplicate_contest = @contest.dup
    duplicate_contest.user = users(:userTwo)
    duplicate_contest.shortname = 'another short name'
    @contest.save
    assert duplicate_contest.valid?
  end

  test "shortname must be unique within user" do
    duplicate_contest = @contest.dup
    duplicate_contest.shortname = @contest.shortname.upcase
    duplicate_contest.name = 'another name'
    @contest.save
    assert_not duplicate_contest.valid?
  end

  test "shortname may be duplicate with other user" do
    duplicate_contest = @contest.dup
    duplicate_contest.user = users(:userTwo)
    duplicate_contest.name = 'another name'
    @contest.save
    assert duplicate_contest.valid?
  end
end
