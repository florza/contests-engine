class DrawManagerGroups < DrawManager

  validate :validate_groups

  ##
  # Groups specific initialization:
  # If the given tableau does not yet contain all participants
  # the  groups structure with the target size of each group is determined
  # and the groups are filled up to their target size with 0.

  def initialize(params)
    super
    if @drawn_participants.size != @participants.size
        # || @draw_tableau.size != @contest.ctype_params['draw_tableau'].size
      if (groups_structure = get_groups_structure(
          @participants.size, @draw_tableau.size)) == [[]]
        return
      end
      @draw_tableau.dup.each_with_index do |group, grp_nr0|
        size_difference = groups_structure[grp_nr0].size - group.size
        if size_difference > 0
          @draw_tableau[grp_nr0] =
              group + [0] * size_difference
        elsif size_difference < 0
          @draw_tableau[grp_nr0] = group.slice(0, group.size + size_difference)
          # recalculate @drawn_participants, eventually a participant was
          # deleted from the tableau by the preceding operation!
          @drawn_participants = @draw_tableau.flatten.select {|p| p.to_i > 0}
        end
      end
    end
  end

  ##
  # Return an empty draw tableau for the acual number of participants and
  # the number of groups given by the number of subarrays of the draw tableau.
  # This is used to answer a 'GET /contest/{id}/draw' request. It will get back
  # a tableau with an optimal distribution of group sizes and 0 at the places to be filled with participant ids

  def draw_structure
    return get_groups_structure(@participants.size, @draw_tableau.size)
  end

  private

  ##
  # Create all matches for the contest, all participants are drawn.

  def create_matches
    @contest.matches.destroy_all
    @draw_tableau.each_with_index do |members, group0|
      matches = Schedule.get_group_schedule(members, false)
      super(group0 + 1, matches)
    end
  end

  ##
  # Validation methods

  def validate_groups
    validate_draw_allowed
    validate_drawn_uniqueness
    validate_drawn_ids
    validate_groups_sizes
  end

  def validate_groups_sizes
    if @draw_tableau.size * 2 > @participants.size
      errors.add(:draw_tableau, "too many groups for number of participants")
      return
    end
    @draw_tableau.each do |group|
      if group.size < 2
        errors.add(:draw_tableau, 'group size must not be 1 or less')
        return
      end
    end
  end

  ##
  # Complement an empty or partially filled tableau by placing
  # the not yet drawn participants randomly in the remaining slots.

  def complement_draw
    ppants_to_draw = @participants.
      select {|p| !@drawn_participants.include?(p.id)}
    pos_to_draw = []
    @draw_tableau.each_with_index do |group, grp_nr0|
      group.each_with_index do |pos, grp_pos0|
        if pos == 0
          pos_to_draw << [grp_nr0, grp_pos0]
        end
      end
    end
    pos_to_draw.each do |group0, pos0|
      draw = rand(ppants_to_draw.size)
      @draw_tableau[group0][pos0] = ppants_to_draw[draw].id
      ppants_to_draw.delete_at(draw)
    end
    raise 'Unknown error during draw' if ppants_to_draw.size != 0
    @drawn_participants = @draw_tableau.flatten.select {|p| p.to_i > 0}
  end

  ##
  # Define the sizes of the groups for given numbers of participants and groups.
  # The computed group sizes follow these rules:
  # - Groups sizes must be at least 2.
  # - The sizes are all equal or differ only by 1.
  # - There are not more than 2 different group sizes.
  # - If group winners go ahead to a final KO part of the contest and
  #   the number of groups is not a power of 2, the "missing" groups are placed
  #   in the same order as the BYEs in a KO tableau.
  # - The positions of the groups with smaller size are also derived from a
  #   KO tableau for the given number of groups. The s smaller groups
  #   are placed at the positions of the s first seeds.
  #
  #   12 participants, 4 groups: [3, 3, 3, 3]
  #   11 participants, 4 groups: [2, 3, 3, 3]
  #   13 participants, 4 groups: [3, 4, 3, 3]
  #   10 participants, 3 groups: [3,    4, 3]

  def get_groups_structure(nbr_ppants, nbr_groups)
    return [[]] if nbr_ppants < nbr_groups * 2
    min_group_size = (nbr_ppants.to_f / nbr_groups).floor
    max_group_size = (nbr_ppants.to_f / nbr_groups).ceil
    groups = [[0] * max_group_size] * nbr_groups
    if min_group_size != max_group_size
      downsize_groups!(groups, nbr_groups * max_group_size - nbr_ppants)
    end
    return groups
  end

  ##
  # Determine the 'nbr_downsizes' groups that must be smaller than the
  # other groups. These are the groups that would be at the positions
  # of the first 'nbr_downsizes' seeded players in a KO tableau with
  # 'number of groups' filled positions.
  # Reduce the size of these groups by deleting their first element.

  def downsize_groups!(groups, nbr_downsizes)
    structure = get_ko_structure(groups.size)
    groupNr = 0
    structure.each do |pos|
      next if pos == 'BYE'  # there is no group at BYE positions!
      if pos <= nbr_downsizes
        groups[groupNr] = groups[groupNr][1..-1]
      end
      groupNr += 1
    end
  end
end
