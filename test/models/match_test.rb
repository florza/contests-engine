require 'test_helper'

class MatchTest < ActiveSupport::TestCase

  def setup
    @match = Match.new(
      contest: contests(:DemoMeisterschaft),
      remarks: ''
    )
  end

  test "sample match is valid" do
    assert @match.valid?
  end

  test "required attributes must be set" do
    [:contest_id].each do |attr|
      match2 = @match.dup
      match2[attr] = nil
      assert_not match2.valid?, "Empty #{attr.to_s} must be invalid"
    end
  end
end
