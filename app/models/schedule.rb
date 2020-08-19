# Create the schedule for a group
# i.e. an array of [round, "home"-participant, "away"-participant]
#
# Ideas from: http:#www-i1.informatik.rwth-aachen.de/~algorithmus/algo36.php
#             https:#github.com/deezaster/spielplan
# ---------------------------------------------------------------------
# @license    http:#www.opensource.org/licenses/bsd-license.php  BSD License
#

class Schedule

  def self.get_group_schedule(members, return_matches = false)

    matches = []
    grp_size = members.count
    rounds = grp_size.even? ? grp_size -1 : grp_size

    1.upto(rounds) do |round|
      home = grp_size
      away = round
      # swap home and away-team in every second round
      home, away = away, home if round.odd?

      if grp_size.even?
        # first match of round is left out with odd group sizes
        matches.push( { round: round,
                        home: members[home - 1],
                        away: members[away - 1] } )
      end

      1.upto((rounds + 1) / 2 - 1) do |match|
        if round - match < 0
          away = rounds + (round - match);
        else
          away = (round - match) % rounds;
          away = rounds if away == 0 # 0 -> n-1
        end

        home = (round + match) % rounds;
        home = rounds if home == 0    # 0 -> n-1

        # heimspiel? auswärtsspiel?
        if match.even?
          home, away = away, home
        end

        matches.push( { round: round,
                        home: members[home - 1],
                        away: members[away - 1] } )
      end
    end

    # Copy matches to return_matches
    if return_matches
      nbr_matches = matches.count
      0.upto(nbr_matches - 1) do |m|
        matches.push( { round: (matches[m][:round] + rounds),
                        home: matches[m][:away],
                        away: matches[m][:home] } )
      end
    end

    matches
  end
end
