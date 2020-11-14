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

  ##
  # Because the feature had to be implemented in the controller and not in the
  # model validations, the test is also included here.
  # Correctly, it should be in participant_test.rb, where also the test
  # "participant must not be added if a draw exists" is.
  test "should not destroy participant if a draw exists" do
    draw_demomeisterschaft
    delete api_v1_contest_participant_url(@contest, @participant),
            headers: @headers, as: :json
    assert_response :unprocessable_entity
    assert_includes JSON.parse(response.body)['errors'][0]['detail'],
      'Participant must not be deleted if a draw exists'
  end
end
