require 'test_helper'

class DrawManagerKOTest < ActiveSupport::TestCase

  def setup
    @contest = contests(:DemoKO)
    @full_params = {
      contest_id: @contest.id,  # simulates the id coming from the url
      data: { type: 'contests',
              id: @contest.id,
              attributes: { draw_tableau: [ [ participants(:DKO1).id,
                                              'BYE',
                                              participants(:DKO2).id,
                                              participants(:DKO3).id,
                                              participants(:DKO4).id,
                                              participants(:DKO5).id,
                                              'BYE',
                                              participants(:DKO6).id ] ] } }
    }
  end

  test "empty tableau is valid" do
    draw_params = @full_params
    draw_params[:data][:attributes] = { draw_tableau: [[]] }
    mgr = DrawManagerKO.new(draw_params)
    assert mgr.valid?
  end

  test "all participants set is valid" do
    draw_params = @full_params
    mgr = DrawManagerKO.new(draw_params)
    assert mgr.valid?
  end

  test "some participants set is valid" do
    draw_params = @full_params
    draw_params[:data][:attributes][:draw_tableau][0][2] = 0
    draw_params[:data][:attributes][:draw_tableau][0][7] = 0
    mgr = DrawManagerKO.new(draw_params)
    assert mgr.valid?
  end

  test "no tableau gets corrected to valid" do
    draw_params = @full_params
    draw_params[:data][:attributes] = { draw_tableau: nil }
    mgr = DrawManagerKO.new(draw_params)
    assert mgr.valid?
    assert mgr.draw_structure[0].is_a?(Array)
    assert mgr.draw_structure[0].size == 8
  end

  test "one-level tableau gets corrected to valid" do
    draw_params = @full_params
    draw_params[:data][:attributes] = { draw_tableau: [] }
    mgr = DrawManagerKO.new(draw_params)
    assert mgr.valid?
    assert mgr.draw_structure[0].is_a?(Array)
    assert mgr.draw_structure[0].size == 8
  end

  test "tableau with some get corrected to valid" do
    draw_params = @full_params
    draw_params[:data][:attributes] = { draw_tableau: [ [0, 0, 0, 0, 0] ] }
    mgr = DrawManagerKO.new(draw_params)
    assert mgr.valid?
    assert mgr.draw_structure[0].is_a?(Array)
    assert mgr.draw_structure[0].size == 8
  end

  test "tableau with more than 1 group is invalid" do
    draw_params = @full_params
    draw_params[:data][:attributes] = { draw_tableau: [ [0, 0], [0, 0] ] }
    mgr = DrawManagerKO.new(draw_params)
    assert_not mgr.valid?
  end

  test "invalid participant is invalid" do
    draw_params = @full_params
    draw_params[:data][:attributes][:draw_tableau][0][3] = 123456
    mgr = DrawManagerKO.new(draw_params)
    assert_not mgr.valid?
  end

  test "too many of BYE positions is invalid" do
    draw_params = @full_params
    draw_params[:data][:attributes][:draw_tableau][0][3] = 'BYE'
    mgr = DrawManagerKO.new(draw_params)
    assert_not mgr.valid?
  end

  test "too few BYE positions is invalid" do
    draw_params = @full_params
    draw_params[:data][:attributes][:draw_tableau][0][1] = 0
    mgr = DrawManagerKO.new(draw_params)
    assert_not mgr.valid?
  end

  test "BYE at non-standard position is valid" do
    draw_params = @full_params
    draw_params[:data][:attributes][:draw_tableau][0][1] =
      draw_params[:data][:attributes][:draw_tableau][0][2]
    draw_params[:data][:attributes][:draw_tableau][0][2] = 'BYE'
    mgr = DrawManagerKO.new(draw_params)
    assert mgr.valid?
  end

  test "two BYEs at succeding odd and even index is valid" do
    draw_params = @full_params
    draw_params[:data][:attributes][:draw_tableau][0][1] =
      draw_params[:data][:attributes][:draw_tableau][0][3]
    draw_params[:data][:attributes][:draw_tableau][0][3] = 'BYE'
    draw_params[:data][:attributes][:draw_tableau][0][6] =
      draw_params[:data][:attributes][:draw_tableau][0][4]
    draw_params[:data][:attributes][:draw_tableau][0][4] = 'BYE'
    mgr = DrawManagerKO.new(draw_params)
    assert mgr.valid?
  end

  test "two BYEs at succeding even and odd index is invalid" do
    draw_params = @full_params
    draw_params[:data][:attributes][:draw_tableau][0][1] =
      draw_params[:data][:attributes][:draw_tableau][0][2]
    draw_params[:data][:attributes][:draw_tableau][0][2] = 'BYE'
    draw_params[:data][:attributes][:draw_tableau][0][6] =
      draw_params[:data][:attributes][:draw_tableau][0][3]
    draw_params[:data][:attributes][:draw_tableau][0][3] = 'BYE'
    mgr = DrawManagerKO.new(draw_params)
    assert_not mgr.valid?
  end

  test "tableau must not contain the same participant twice" do
    draw_params = @full_params
    draw_params[:data][:attributes][:draw_tableau][0][4] =
      draw_params[:data][:attributes][:draw_tableau][0][7]
    mgr = DrawManagerKO.new(draw_params)
    assert_not mgr.valid?
  end

  test "draw with same tableau as before is unchanged" do
    draw_params = @full_params
    mgr = DrawManagerKO.new(draw_params)
    mgr.draw
    @contest = Contest.find(contests(:DemoKO).id)
    new_draw = @contest.ctype_params['draw_tableau']
    assert_equal @full_params[:data][:attributes][:draw_tableau], new_draw
  end

  test "empty draw is filled up randomly" do
    draw_params = @full_params
    draw_params[:data][:attributes] =
      { draw_tableau: [ [0, 'BYE', 0, 0, 0, 0, 'BYE', 0] ] }
    last_draw = []
    [0..2].each do |i|
      mgr = DrawManagerKO.new(draw_params)
      mgr.draw
      @contest = Contest.find(contests(:DemoKO).id)
      new_draw = @contest.ctype_params['draw_tableau']
      assert_equal 'BYE', new_draw[0][1]
      assert_equal 'BYE', new_draw[0][6]
      assert_equal 7, new_draw[0].uniq.size
      assert_not_equal last_draw, new_draw
      last_draw = new_draw.dup
    end
  end

  test "empty draw without byes is filled up randomly" do
    draw_params = @full_params
    draw_params[:data][:attributes] = { draw_tableau: [ [0, 0, 0, 0, 0, 0] ] }
    last_draw = []
    [0..2].each do |i|
      mgr = DrawManagerKO.new(draw_params)
      mgr.draw
      @contest = Contest.find(contests(:DemoKO).id)
      new_draw = @contest.ctype_params['draw_tableau']
      assert_equal 'BYE', new_draw[0][1]
      assert_equal 'BYE', new_draw[0][6]
      assert_equal 7, new_draw[0].uniq.size
      assert_not_equal last_draw, new_draw
      last_draw = new_draw.dup
    end
  end

  test "draw with empty slots is filled up" do
    draw_params = @full_params
    draw_params[:data][:attributes][:draw_tableau][0][4] =
      draw_params[:data][:attributes][:draw_tableau][0][7] = 0
    mgr = DrawManagerKO.new(draw_params)
    mgr.draw
    @contest = Contest.find(contests(:DemoKO).id)
    new_draw = @contest.ctype_params['draw_tableau']
    [0, 1, 2, 3, 5, 6].each do |pos|
      assert_equal @full_params[:data][:attributes][:draw_tableau][0][pos], new_draw[0][pos]
    end
    assert_includes [new_draw[0][4],new_draw[0][7]],
      @full_params[:data][:attributes][:draw_tableau][0][4]
    assert_includes [new_draw[0][4],new_draw[0][7]],
      @full_params[:data][:attributes][:draw_tableau][0][7]
  end

end
