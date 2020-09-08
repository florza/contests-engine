class DrawManagerKO < DrawManager

  validate :validate_ko

  ##
  # KO specific initialization:
  # If the sent tableau does not yet contain any participants, the tableau
  # structure with the correct number and placing of eventual BYEs is defined.
  # @draw_tableau for KO has the same two-level structure as a group tableau,
  # but so far contains only 1 group. (This could change , e.g in a
  # double elimination contest with a loosers tableau or a contest where
  # ALL ranks are played out.)
  # To make the handling of this structure easier and more readable,
  # @ko_tableau is defined as a "shorthand" for @draw_tableau.first.

  def initialize(contest, params)
    super
    if @draw_tableau.first.size != get_tableau_size(contest.participants.count)
      @draw_tableau[0] =
        get_ko_structure(@participants.size).map {|p| p == 'BYE' ? p : 0}
    end
    @ko_tableau = @draw_tableau.first
  end

  ##
  # Return an empty draw tableau for the acual number of participants.
  # This is used to answer a 'GET /contest/{id}/draw' request. It will get back
  # a tableau with the correct size (a power of 2), if needed with BYEs at the
  # standard positions and 0 at the places to be filled with participant ids.

  def draw_structure
    return [get_ko_structure(@participants.size).map {|p| p == 'BYE' ? p : 0}]
  end

  private

  ##
  # Create all matches for the contest, with already known ore still
  # empty participants.
  # The matches are created in reverse order of play, starting with the final,
  # so when an earlier match is created, the match_id of its successor is
  # already known and has been placed in match_ids.

  def create_matches
    match_ids = {}
    matches = Schedule.get_ko_schedule(@ko_tableau).sort
    @contest.matches.destroy_all
    super(1, matches, match_ids = match_ids)
  end

  ##
  # This method is called back from super.create_matches for every
  # newly created match, just before it is saved. It can fill
  # ctype-specific fields that are not filled by the general method.

  def create_matches_before_save(match, match_ids)
    params = match.ctype_params
    if params['draw_round'] > 1
      next_round = params['draw_round'] / 2
      next_pos = (params['draw_pos'] / 2.0).ceil
      match.winner_next_match_id = match_ids[[next_round, next_pos]]
      match.winner_next_place_1 = params['draw_pos'].odd?
    end
  end

  ##
  # Validation methods

  def validate_ko
    validate_ko_1group
    validate_ko_size
    validate_ko_byes
    validate_drawn_uniqueness
    validate_drawn_ids
  end

  def validate_ko_1group
    if @draw_tableau.size != 1
      errors.add(:draw_tableau, "must be an array with exactly 1 array of positions")
    end
  end

  def validate_ko_size
    tableau_size = get_tableau_size(@participants.size)
    if @ko_tableau.size != tableau_size
      errors.add(:draw_tableau, "must contain #{tableau_size} positions")
    end
  end

  def validate_ko_byes
    nbrByes = 0
    @ko_tableau.each_with_index do |pos, index|
      if pos == 'BYE'
        nbrByes += 1
        if index.odd? && @ko_tableau[index - 1] == 'BYE'
          errors.add(:draw_tableau, "two BYEs cannot play against each other")
        end
      end
    end
    if nbrByes + @participants.size != @ko_tableau.size
      errors.add(:draw_tableau, "incorrect number of BYEs")
    end
  end

  ##
  # Complement an empty or partially filled tableau by placing
  # the not yet drawn participants randomly in the remaining slots.

  def complement_draw
    ppants_to_draw = @participants.select {|p| !@ko_tableau.include?(p.id) }
    pos_to_draw = @ko_tableau.each_with_index.select {|p, i| p == 0}
    pos_to_draw.each do |p, i|
      draw = rand(ppants_to_draw.size)
      @ko_tableau[i] = ppants_to_draw[draw].id
      ppants_to_draw.delete_at(draw)
    end
    raise 'Unknown error during draw' if ppants_to_draw.size != 0
    @drawn_participants = @draw_tableau.flatten.select {|p| p.to_i > 0}
  end

  ##
  # Size of the KO tableau for n participants, i.e.
  # the smallest power of 2 which is >= n

  def get_tableau_size(n)
    2**Math.log(n, 2).ceil
  end

end
