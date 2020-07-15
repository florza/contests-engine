require 'test_helper'

class ParticipantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @participant = participants(:rogerDemo)
    login_userOne
  end

  test "should get index" do
    get api_v1_participants_url, as: :json
    assert_response :success
  end

  test "should create participant" do
    assert_difference('Participant.count') do
      post api_v1_participants_url, params: { participant: { name: @participant.name, shortname: @participant.shortname } }, as: :json
    end

    assert_response 201
  end

  test "should show participant" do
    get api_v1_participant_url(@participant), as: :json
    assert_response :success
  end

  test "should update participant" do
    patch api_v1_participant_url(@participant), params: { participant: { name: @participant.name, shortname: @participant.shortname } }, as: :json
    assert_response 200
  end

  test "should destroy participant" do
    assert_difference('Participant.count', -1) do
      delete api_v1_participant_url(@participant), as: :json
    end

    assert_response 204
  end
end
