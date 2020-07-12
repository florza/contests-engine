require 'test_helper'

class TeilnehmersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @teilnehmer = teilnehmers(:one)
  end

  test "should get index" do
    get teilnehmers_url, as: :json
    assert_response :success
  end

  test "should create teilnehmer" do
    assert_difference('Teilnehmer.count') do
      post teilnehmers_url, params: { teilnehmer: { kurzname: @teilnehmer.kurzname, name: @teilnehmer.name, teilnehmer_id: @teilnehmer.teilnehmer_id, user_id: @teilnehmer.user_id } }, as: :json
    end

    assert_response 201
  end

  test "should show teilnehmer" do
    get teilnehmer_url(@teilnehmer), as: :json
    assert_response :success
  end

  test "should update teilnehmer" do
    patch teilnehmer_url(@teilnehmer), params: { teilnehmer: { kurzname: @teilnehmer.kurzname, name: @teilnehmer.name, teilnehmer_id: @teilnehmer.teilnehmer_id, user_id: @teilnehmer.user_id } }, as: :json
    assert_response 200
  end

  test "should destroy teilnehmer" do
    assert_difference('Teilnehmer.count', -1) do
      delete teilnehmer_url(@teilnehmer), as: :json
    end

    assert_response 204
  end
end
