require 'test_helper'

class ParticipantTest < ActiveSupport::TestCase

  def setup
    @participant = Participant.new(
      contest: contests(:DemoMeisterschaft),
      user: users(:userOne),
      name: 'name',
      shortname: 'short name',
      remarks: 'remarks'
    )
  end

  test "sample participant is valid" do
    assert @participant.valid?
  end

  test "required attributes must be set" do
    [:user_id, :name, :shortname, :remarks].each do |attr|
      participant2 = @participant.dup
      participant2[attr] = nil
      assert_not participant2.valid?, "Empty #{attr.to_s} must be invalid"
    end
  end

  test "name must be unique within contest" do
    duplicate_participant = @participant.dup
    duplicate_participant.name = @participant.name.upcase
    duplicate_participant.shortname = 'another short name'
    @participant.save
    assert_not duplicate_participant.valid?
  end

  test "name may be duplicate with other contest" do
    duplicate_participant = @participant.dup
    duplicate_participant.contest = contests(:DemoKO)
    duplicate_participant.shortname = 'another short name'
    @participant.save
    assert duplicate_participant.valid?
  end

  test "shortname must be unique within user" do
    duplicate_participant = @participant.dup
    duplicate_participant.shortname = @participant.shortname.upcase
    duplicate_participant.name = 'another name'
    @participant.save
    assert_not duplicate_participant.valid?
  end

  test "shortname may be duplicate with other user" do
    duplicate_participant = @participant.dup
    duplicate_participant.contest = contests(:DemoKO)
    duplicate_participant.name = 'another name'
    @participant.save
    assert duplicate_participant.valid?
  end
end
