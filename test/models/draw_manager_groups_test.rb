require 'test_helper'

class DrawManagerGroupsTest < ActiveSupport::TestCase

  def setup
    @contest = contests(:DemoGruppen)
    @full_params = { draw_tableau: [ [participants(:Roger).id,
                                      participants(:Martina).id,
                                      participants(:Pete).id],
                                     [participants(:Rod).id,
                                      participants(:Raffa).id,
                                      participants(:Stan).id,
                                      participants(:Steffi).id] ] }
  end

  test "empty tableau is valid" do
    draw_params = { draw_tableau: [[]] }
    mgr = DrawManagerGroups.new(@contest, draw_params)
    assert mgr.valid?
  end

  test "all participants set is valid" do
    draw_params = @full_params
    mgr = DrawManagerGroups.new(@contest, draw_params)
    assert mgr.valid?
  end

  test "some participants set is valid" do
    draw_params = @full_params
    draw_params[:draw_tableau][0][2] = 0
    draw_params[:draw_tableau][1][3] = 0
    mgr = DrawManagerGroups.new(@contest, draw_params)
    assert mgr.valid?
  end

  test "no tableau gets corrected to valid" do
    draw_params = { draw_tableau: nil }
    mgr = DrawManagerGroups.new(@contest, draw_params)
    assert mgr.valid?
    assert mgr.draw_structure[0].is_a?(Array)
  end

  test "one-level tableau gets corrected to valid" do
    draw_params = { draw_tableau: [] }
    mgr = DrawManagerGroups.new(@contest, draw_params)
    assert mgr.valid?
    assert mgr.draw_structure[0].is_a?(Array)
  end

  test "tableau with empty groups is valid" do
    draw_params = { draw_tableau: [ [], [], [] ] }
    mgr = DrawManagerGroups.new(@contest, draw_params)
    assert mgr.valid?
  end

  # TODO Is valid now because the invalid tableau gets replaced by a valid one.
  #      Is this ok or would it be better to return an error?
  test "tableau with more than n/2 groups is? valid" do
    draw_params = { draw_tableau: [ [], [], [], [] ] }
    mgr = DrawManagerGroups.new(@contest, draw_params)
    assert mgr.valid?
  end

  # TODO Is valid now because the invalid tableau gets replaced by a valid one.
  #      Is this ok or would it be better to return an error?
  test "tableau with group of 1 is? valid" do
    draw_params = { draw_tableau: [ [0, 0, 0], [0], [0, 0, 0] ] }
    mgr = DrawManagerGroups.new(@contest, draw_params)
    assert mgr.valid?
  end

  test "invalid participant is invalid" do
    draw_params = @full_params
    draw_params[:draw_tableau][0][2] = 123456
    mgr = DrawManagerGroups.new(@contest, draw_params)
    assert_not mgr.valid?
  end

  test "tableau must not contain the same participant twice" do
    draw_params = @full_params
    draw_params[:draw_tableau][1][2] = draw_params[:draw_tableau][0][1]
    mgr = DrawManagerGroups.new(@contest, draw_params)
    assert_not mgr.valid?
  end

  test "draw with same tableau as before is unchanged" do
    draw_params = @full_params
    mgr = DrawManagerGroups.new(@contest, draw_params)
    mgr.draw
    assert_equal @full_params[:draw_tableau], mgr.draw_structure
  end

  test "empty draw is filled up randomly" do
    draw_params = { draw_tableau: [ [0, 0, 0], [0, 0, 0, 0] ] }
    last_draw = []
    [0..2].each do |draw|
      mgr = DrawManagerGroups.new(@contest, draw_params)
      mgr.draw
      new_draw = mgr.draw_structure
      assert_equal 7, new_draw.flatten.uniq.size
      assert_not_equal last_draw, new_draw
      last_draw = new_draw.dup
    end
  end

  test "draw with empty slots is filled up" do
    draw_params = @full_params
    draw_params[:draw_tableau][0][1] = draw_params[:draw_tableau][1][2] = 0
    mgr = DrawManagerGroups.new(@contest, draw_params)
    mgr.draw
    new_draw = mgr.draw_structure
    [ [0, 0], [0, 2], [1, 0], [1, 1], [1, 3] ].each do |g, p|
      assert_equal @full_params[:draw_tableau][g][p], new_draw[g][p]
    end
    assert_includes [new_draw[0][1],new_draw[1][2]],
        @full_params[:draw_tableau][0][1]
    assert_includes [new_draw[0][1],new_draw[1][2]],
        @full_params[:draw_tableau][1][2]
  end

end
