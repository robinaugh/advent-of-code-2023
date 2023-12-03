require 'optparse'

class Base
  GridNumber = Struct.new(:number, :x_range, :y, keyword_init: true)
  GridGear = Struct.new(:x, :y, :grid_numbers, keyword_init: true) do
    def valid?
      grid_numbers.count == 2
    end

    def ratio
      grid_numbers.map { _1.number.to_i }.inject(:*)
    end
  end

  attr_reader :grid, :input

  def initialize(input)
    @input = input
    @grid = input.map(&:chars)
  end

  private

  def _scan_row(row, regex)
    row.enum_for(:scan, regex).map { |m| [m, $~.offset(0)[0]] }
  end

  def _to_grid_number(row, row_index)
    _scan_row(row, /\d+/).map do |number, x_index|
      x_range = x_index..(x_index + number.length - 1)
      GridNumber.new(number: number, x_range: x_range, y: row_index)
    end
  end

  def _to_grid_gear(row, row_index)
    _scan_row(row, /[*]/).map do |gear, x_index|
      GridGear.new(x: x_index, y: row_index)
    end
  end

  def _adjacent_symbols?(grid_number)
    _adjacent_characters(grid_number.x_range, grid_number.y).any? { _1.match?(/[^a-zA-Z0-9.]/) }
  end

  def _adjacent_characters(x_range, y)
    characters = []
    adjacent_range = [x_range.begin - 1, 0].max..[x_range.end + 1, grid[y].size - 1].min

    row_above = grid[y - 1] if y.positive?
    characters << row_above[adjacent_range] if row_above

    row = grid[y]
    characters << row[x_range.begin - 1] if x_range.begin.positive?
    characters << row[x_range.end + 1]

    row_below = grid[y + 1]
    characters << row_below[adjacent_range] if row_below

    characters.flatten.compact
  end

  def _gear_touches_grid_number?(gear, grid_number)
    return false unless gear.x.between? grid_number.x_range.begin - 1, grid_number.x_range.end + 1

    gear.y.between? grid_number.y - 1, grid_number.y + 1
  end
end

class Part1 < Base
  def run
    input
      .each_with_index
      .map(&method(:_to_grid_number))
      .flatten
      .filter(&method(:_adjacent_symbols?))
      .map(&:number)
      .sum(&:to_i)
  end
end

class Part2 < Base
  def run
    gears = input
      .each_with_index
      .map(&method(:_to_grid_gear))
      .flatten

    grid_numbers = input
      .each_with_index
      .map(&method(:_to_grid_number))
      .flatten

    gears.each do |gear|
      gear.grid_numbers = grid_numbers.filter { _gear_touches_grid_number?(gear, _1) }
    end

    gears.filter(&:valid?).map(&:ratio).sum
  end
end

if __FILE__ == $PROGRAM_NAME
  options = {}
  OptionParser.new do |opts|
    opts.banner = "Usage: day03.rb [options]"

    opts.on("-p", "--part PART", "Part to run") do |p|
      options[:part] = p
    end

    opts.on("-i", "--input INPUT", "Input file") do |i|
      options[:input_file] = i
    end
  end.parse!

  part = options[:part]
  input_file = options[:input_file]

  input = File.readlines(input_file).map(&:chomp)

  if part == '1'
    puts Part1.new(input).run
  elsif part == '2'
    puts Part2.new(input).run
  else
    puts "Invalid part argument. Please specify either '1' or '2'."
  end
end