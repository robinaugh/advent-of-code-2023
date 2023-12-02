def part_1(strings)
  values = strings.map do |str|
    numbers = str.chars.grep(/\d/)
    (numbers[0] + numbers[-1]).to_i
  end

  values.sum
end

def part_2(strings)
  words = %w(zero one two three four five six seven eight nine)

  values = strings.map do |str|
    first_val = str.match(/#{words.join('|')}|\d/).to_s
    last_val = str.reverse.match(/#{words.map(&:reverse).join('|')}|\d/).to_s.reverse

    [first_val, last_val].map do |val|
      words.index(val) || val
    end.join.to_i
  end

  values.sum
end