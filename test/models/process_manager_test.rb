require 'test_helper'

class ProcessManagerTest < ActiveSupport::TestCase

  def setup
    @match = Match.new(
      contest: contests(:DemoMeisterschaft),
      participant_1: participants(:DM1),
      participant_2: participants(:DM2),
      ctype_params: {"draw_group"=>1, "draw_round"=>1}
    )
    # save new match, process_results runs only on update
    @match.save!
  end

  test "match stats are computed on save" do
    @match.result = {}
    @match.result['score_p1'] = [2,7,6]
    @match.result['score_p2'] = [6,5,3]
    @match.winner_id = @match.participant_1_id
    @match.save!
    assert_equal "2:6 / 7:5 / 6:3", Result.to_s(@match.result)

    assert_equal [3, 0], @match.stats['points']
    assert_equal [1, 0, 0], @match.stats['matches']
    assert_equal [2, 0, 1], @match.stats['sets']
    assert_equal [15, 14], @match.stats['games']
  end

  test "match stats are deleted on update with no result" do
    @match.result = {}
    @match.result['score_p1'] = [2,7,6]
    @match.result['score_p2'] = [6,5,3]
    @match.winner_id = @match.participant_1_id
    @match.save!
    assert_equal 4, @match.stats.size

    @match.update!({ result: nil, winner_id: nil})

    assert_equal Result.empty_match_stats, @match.stats
  end

  test "participant stats are computed on match save" do
    @match.result = {}
    @match.result['score_p1'] = [2,7,6]
    @match.result['score_p2'] = [6,5,3]
    @match.winner_id = @match.participant_1_id
    @match.save!
    assert_equal 4, @match.stats.size

    dm1 = Participant.find(participants(:DM1).id)
    assert_equal 3, dm1.stats['points']
    assert_equal [1, 0, 0], dm1.stats['matches']
    assert_equal [2, 0, 1], dm1.stats['sets']
    assert_equal [15, 14], dm1.stats['games']

    dm2 = Participant.find(participants(:DM2).id)
    assert_equal 0, dm2.stats['points']
    assert_equal [0, 0, 1], dm2.stats['matches']
    assert_equal [1, 0, 2], dm2.stats['sets']
    assert_equal [14, 15], dm2.stats['games']
  end

  test "participant stats are added over several matches" do
    contest = @match.contest
    contest.result_params['tie_allowed'] = true
    contest.save!

    @match.result = {}
    @match.result['score_p1'] = [2,7,6]
    @match.result['score_p2'] = [6,5,3]
    @match.winner_id = @match.participant_1_id
    @match.save!
    assert_equal 4, @match.stats.size

    @match2 = Match.new(
      contest: contests(:DemoMeisterschaft),
      participant_1: participants(:DM1),
      participant_2: participants(:DM3),
      ctype_params: {"draw_group"=>1, "draw_round"=>1}
    )
    @match2.save!

    @match2.result = {}
    @match2.result['score_p1'] = [6,7]
    @match2.result['score_p2'] = [0,5]
    @match2.winner_id = @match2.participant_1_id
    @match2.save!
    assert_not_nil @match2.id
    assert_not_nil @match2.participant_1_id
    assert_not_nil @match2.participant_2_id
    assert_equal 4, @match2.stats.size

    @match3 = Match.new(
      contest: contests(:DemoMeisterschaft),
      participant_1: participants(:DM3),
      participant_2: participants(:DM2),
      ctype_params: {"draw_group"=>1, "draw_round"=>1},
    )
    @match3.save!

    @match3.result = {}
    @match3.result['score_p1'] = [6,1,5]
    @match3.result['score_p2'] = [3,6,5]
    @match3.winner_id = 0
    @match3.save!
    assert_not_nil @match3.id
    assert_equal 4, @match3.stats.size

    #pp Match.all.select(:id, :contest_id, :stats)
    #pp Participant.all.select(:id, :shortname, :stats)

    dm1 = Participant.find(participants(:DM1).id)
    assert_equal 6, dm1.stats['points']
    assert_equal [2, 0, 0], dm1.stats['matches']
    assert_equal [4, 0, 1], dm1.stats['sets']
    assert_equal [28, 19], dm1.stats['games']

    dm2 = Participant.find(participants(:DM2).id)
    assert_equal 1, dm2.stats['points']
    assert_equal [0, 1, 1], dm2.stats['matches']
    assert_equal [2, 1, 3], dm2.stats['sets']
    assert_equal [28, 27], dm2.stats['games']

    dm3 = Participant.find(participants(:DM3).id)
    assert_equal 1, dm3.stats['points']
    assert_equal [0, 1, 1], dm3.stats['matches']
    assert_equal [1, 1, 3], dm3.stats['sets']
    assert_equal [17, 27], dm3.stats['games']
  end
end
