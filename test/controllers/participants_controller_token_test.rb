require 'test_helper'

class ParticipantsControllerTokenTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
    @participant = participants(:rogerDemo)
    @token_read = "?t=#{@contest.token_read}"
    @token_write = "?t=#{@contest.token_write}"
  end

  test "should get index of contests participants with token" do
    get api_v1_contest_participants_url(@contest) + @token_read, as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_equal 2, result.count
  end

  test "should show participant with token" do
    get api_v1_contest_participant_url(@contest, @participant) + @token_read,
          as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_not_nil result.count
  end

  test "should not create participant with token" do
    post api_v1_contest_participants_url(@contest) + @token_write,
        params:   { participant: {name: 'New test participant',
                                  shortname: 'New test',
                                  remarks: 'Remarks'} },
        as: :json
    assert_response 401
  end

  test "should not update participant with token" do
    patch api_v1_contest_participant_url(@contest, @participant) + @token_write,
          params: { participant: {name: @participant.name,
                                  shortname: @participant.shortname,
                                  remarks: @participant.remarks} },
          as: :json
    assert_response 401
  end

  test "should not destroy participant with token" do
    delete api_v1_contest_participant_url(@contest, @participant) + @token_write,
          as: :json
    assert_response 401
  end
end
