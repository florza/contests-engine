require 'test_helper'

class ParticipantsControllerUserTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
    @participant = participants(:rogerDemo)
    login_userOne
  end

  test "should get index of contests participants" do
    get api_v1_contest_participants_url(@contest),
          headers: @headers, as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_equal 2, result.count
  end

  test "should create participant" do
    assert_difference('Participant.count') do
      post api_v1_contest_participants_url(@contest),
          headers: @headers,
          params: { participant: {name: 'New test participant',
                                  shortname: 'New test',
                                  remarks: 'Remarks'} },
          as: :json
    end
    assert_response 201
  end

  test "should show participant" do
    get api_v1_contest_participant_url(@contest, @participant),
          headers: @headers, as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_not_nil result.count
  end

  test "should update participant" do
    patch api_v1_contest_participant_url(@contest, @participant),
          headers: @headers,
          params: { participant: {name: @participant.name,
                                  shortname: @participant.shortname,
                                  remarks: @participant.remarks} },
          as: :json
    assert_response 200
  end

  test "should destroy participant" do
    assert_difference('Participant.count', -1) do
      delete api_v1_contest_participant_url(@contest, @participant),
            headers: @headers, as: :json
    end
    assert_response 204
  end
end
