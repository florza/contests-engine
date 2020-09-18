require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase

  test "list of group matches can be created" do
    members = [111, 222, 333, 444, 555]
    matches = Schedule::get_group_schedule(members, false)
    assert_equal 10, matches.size
  end

  test "list of group matches with return match can be created" do
    members = [111, 222, 333, 444, 555]
    matches = Schedule::get_group_schedule(members, true)
    assert_equal 20, matches.size
  end

  test "list of KO matches can be created" do
    members = [111, 'BYE', 333, 444, 555, 666, 777, 888]
    matches = Schedule::get_ko_schedule(members)
    #p matches
    assert_equal 6, matches.size
  end
end
