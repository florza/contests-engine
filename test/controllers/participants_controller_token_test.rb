require 'test_helper'

class ParticipantsControllerTokenTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
    @participant = participants(:DM2)
  end

  test "should get index of contests participants with token" do
    login_readToken
    get api_v1_contest_participants_url(@contest), headers: @headers, as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_equal 4, result['data'].size
  end

  test "should show participant with token" do
    login_readToken
    get api_v1_contest_participant_url(@contest, @participant),
          headers: @headers, as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_not_nil result['data'].size
  end

  test "should not create participant with token" do
    login_writeToken
    post api_v1_contest_participants_url(@contest),
        headers: @headers,
        params: {
          data: { type: 'participants',
                  attributes: { name: 'New test participant',
                                shortname: 'New test',
                                remarks: 'Remarks'} }
        },
        as: :json
    assert_response 401
  end

  test "should not update participant with token" do
    login_writeToken
    patch api_v1_contest_participant_url(@contest, @participant),
          headers: @headers,
          params: {
            data: { type: 'participants',
                    id: @participant.id,
                    attributes: {name: @participant.name,
                                shortname: @participant.shortname,
                                remarks: @participant.remarks} }
          },
          as: :json
    assert_response 401
  end

  test "should not destroy participant with token" do
    login_writeToken
    delete api_v1_contest_participant_url(@contest, @participant),
          headers: @headers, as: :json
    assert_response 401
  end
end
