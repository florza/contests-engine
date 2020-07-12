require 'test_helper'

class TurniersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @turnier = turniers(:one)
  end

  test "should get index" do
    get turniers_url, as: :json
    assert_response :success
  end

  test "should create turnier" do
    assert_difference('Turnier.count') do
      post turniers_url, params: { turnier: { name: @turnier.name, turnier_id: @turnier.turnier_id } }, as: :json
    end

    assert_response 201
  end

  test "should show turnier" do
    get turnier_url(@turnier), as: :json
    assert_response :success
  end

  test "should update turnier" do
    patch turnier_url(@turnier), params: { turnier: { name: @turnier.name, turnier_id: @turnier.turnier_id } }, as: :json
    assert_response 200
  end

  test "should destroy turnier" do
    assert_difference('Turnier.count', -1) do
      delete turnier_url(@turnier), as: :json
    end

    assert_response 204
  end
end
