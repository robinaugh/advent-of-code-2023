COUNTS_IN_BAG = {
  red: 12,
  green: 13,
  blue: 14
}

def part_1(games)
  valid_game_ids = []

  games.each do |game|
    game_name, *rounds = game.split(/:|;/).map(&:strip)
    game_id = game_name.match(/\d+/).to_s.to_i
    valid_game_ids << game_id if rounds.all? do |round|
      color_counts = round.split(', ').to_h do |color_count|
        count, color = color_count.split(' ')
        [color.to_sym, count.to_i]
      end

      COUNTS_IN_BAG.all? do |color, count_in_bag|
        color_counts.fetch(color, 0) <= count_in_bag
      end
    end
  end

  valid_game_ids.sum
end

def part_2(games)
  powers = []

  games.each do |game|
    _, *rounds = game.split(/:|;/).map(&:strip)
    min_color_map = {}

    rounds.each do |round|
      round.split(', ').each do |color_count|
        count, color = color_count.split(' ')
        min_color_map[color.to_sym] ||= 0
        min_color_map[color.to_sym] = [min_color_map[color.to_sym], count.to_i].max
      end

    end

    powers << min_color_map.values.inject(:*)
  end

  powers.sum
end