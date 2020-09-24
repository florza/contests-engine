require 'test_helper'

class ParticipantsControllerUserTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:DemoMeisterschaft)
    @participant = participants(:DM2)
    login_userOne
  end

  test "should get index of contests participants" do
    get api_v1_contest_participants_url(@contest),
          headers: @headers, as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_equal 4, result['data'].size
  end

  test "should create participant" do
    assert_difference('Participant.count') do
      post api_v1_contest_participants_url(@contest),
          headers: @headers,
          params: {
            data: { type: 'participants',
                    attributes: { name: 'New test participant',
                                  shortname: 'New test',
                                  remarks: 'Remarks'} }
          },
          as: :json
    end
    assert_response 201
  end

  test "should not create invalid participant" do
    post api_v1_contest_participants_url(@contest),
        headers: @headers,
        params: {
            data: { type: 'participants',
                    attributes: { name: 'New test participant',
                                  shortname: '',
                                  remarks: 'Remarks'} }
        },
        as: :json
    assert_response :unprocessable_entity
  end

  test "should show participant" do
    get api_v1_contest_participant_url(@contest, @participant),
          headers: @headers, as: :json
    assert_response :success
    result = JSON.parse(@response.body)
    assert_not_nil result['data']
  end

  test "should update participant" do
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
    assert_response 200
  end

  test "should not update participant with invalid values" do
    patch api_v1_contest_participant_url(@contest, @participant),
          headers: @headers,
          params: {
            data: { type: 'participants',
                    id: @participant.id,
                    attributes: { name: @participant.name,
                                  shortname: '',
                                  remarks: @participant.remarks} }
          },
          as: :json
    assert_response :unprocessable_entity
  end

  test "should destroy participant" do
    assert_difference('Participant.count', -1) do
      delete api_v1_contest_participant_url(@contest, @participant),
            headers: @headers, as: :json
    end
    assert_response 200
  end
end
