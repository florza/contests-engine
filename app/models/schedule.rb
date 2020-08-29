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

    matches = {}
    grp_size = members.size
    rounds = grp_size.even? ? grp_size -1 : grp_size

    1.upto(rounds) do |round|
      home = grp_size
      away = round
      # swap home and away-team in every second round
      home, away = away, home if round.odd?

      if grp_size.even?
        # first match of round is left out with odd group size (no opponent)
        matches[[round, 0]] = { round: round,
                                participant_1_id: members[home - 1],
                                participant_2_id: members[away - 1] }
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

        matches[[round, match]] = { round: round,
                                    participant_1_id: members[home - 1],
                                    participant_2_id: members[away - 1] }
      end
    end

    # Copy matches to return_matches
    if return_matches
      nbr_matches = matches.size
      return_matches = {}
      matches.each do |key, m|
        round = m[:round] + rounds
        return_matches[[round, key[1]]] =
            { round: round,
              participant_1_id: m[:participant_2_id],
              participant_2_id: m[:participant_1_id] }
      end
      matches.merge!(return_matches)
    end

    matches
  end

  def self.get_ko_schedule(ko_tableau)
    matches = {}
    round = firstRound = ko_tableau.size / 2
    while round > 0
      1.upto(round) do |pos|
        pos2 = 2 * pos
        ppant1 = ppant2 = nil
        if round == firstRound
          ppant1 = ko_tableau[pos2 - 2]
          ppant2 = ko_tableau[pos2 - 1]
          if ppant1 == 'BYE' || ppant2 == 'BYE'  # no match in first round
            next
          end
        elsif round == firstRound / 2
          if matches[[2 * round, 2 * pos - 1]].nil?
            ppant1 = ko_tableau[4 * (pos - 1)]  # Bye, winner is in next round
          elsif matches[[2 * round, 2 * pos]].nil?
            ppant2 = ko_tableau[4 * pos - 1]    # Bye, winner is in next round
          end
        end
        matches[[round, pos]] = { participant_1_id: ppant1,
                                  participant_2_id: ppant2,
                                  round: round,
                                  pos: pos }
      end
      round /= 2
    end
    matches
  end
end
