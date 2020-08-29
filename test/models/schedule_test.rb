require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase
  test "list of matches can be created" do
    members = [111, 222, 333, 444]
    matches = Schedule::get_group_schedule(members, true)
    #p matches
    assert_equal 12, matches.size
  end
end
