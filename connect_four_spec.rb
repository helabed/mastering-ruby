require 'rspec/autorun'
require 'securerandom'

a = 'Hello, World'
regex = /llo/
outcome = regex.match?(a)
#puts outcome

regex = /lllo/
outcome = regex.match?(a)
#puts outcome

# 6 rows
# 7 cols
class ConnectFour
  NUM_OF_ROWS = 6
  NUM_OF_COLS = 7

  attr_accessor :row, :board

  def initialize
    @board = []

    NUM_OF_ROWS.times do |i|
      @row = []
      NUM_OF_COLS.times do |i|
        #puts i
        @row << ' '
      end
      @board << @row
    end
  end

  def get_next_available_row(col)
    j = 0
    j < NUM_OF_ROWS
    while j < NUM_OF_ROWS && @board[j][col] != ' '
      j += 1
    end
    return j if j < NUM_OF_ROWS
    return -1
  end

  def check_for_winner
    x_regex = /XXXX/
    o_regex = /OOOO/
    NUM_OF_COLS.times do |i|
      outcome = x_regex.match?(get_column(i).join)
      return true,'X is winner' if outcome
      outcome = o_regex.match?(get_column(i).join)
      return true,'O is winner' if outcome
    end
    return false
  end

  class WinnerDetected < StandardError; end

  def play_board(token, col)
    i = get_next_available_row(col)
    @board[i][col] = token if i >= 0
    raise ArgumentError, "column overflow at col: #{col}" if i < 0
    puts show_board
    puts ""
    sleep 1
    outcome, winner = check_for_winner
    raise WinnerDetected, "Winner detected - #{winner} is the winner!" if outcome
  end

  def get_column(col)
    accumulator = []
    NUM_OF_ROWS.times do |i|
      accumulator << "#{@board[i][col]}"
    end
    return accumulator
  end

  def show_board
    accumulator = []
    NUM_OF_ROWS.times do |i|
      reversed_i = NUM_OF_ROWS - i - 1
      #puts reversed_i
      accumulator << "#{@board[reversed_i]}"
    end
    return accumulator
  end
end

RSpec.describe 'ConnectFour implementation with BDD' do

  it 'should display a human viewable board(i.e inverted) without overflows' do
    cf = ConnectFour.new

    cf.play_board('X', 2)
    cf.play_board('O', 2)
    cf.play_board('X', 2)
    cf.play_board('O', 2)
    cf.play_board('O', 2)
    cf.play_board('X', 2)
    board = cf.show_board
    puts board
    expect(cf.get_column(2)).to eq(['X','O','X','O','O','X'])

    #overflow here
    expect {
      cf.play_board('O', 2)}.to raise_error('column overflow at col: 2')
    expect {
      cf.play_board('X', 2)}.to raise_error('column overflow at col: 2')
  end

  it 'should play board with a random generator' do
    puts ""
    col_randomness_range = 7
    row_randomness_range = 6

    cf = ConnectFour.new
    (ConnectFour::NUM_OF_ROWS * ConnectFour::NUM_OF_COLS).times do |i|
      begin
      col = SecureRandom.random_number(col_randomness_range)
      cf.play_board('X', col)
      col = SecureRandom.random_number(col_randomness_range)
      cf.play_board('O', col)
      rescue ArgumentError
        # do nothing
      rescue ConnectFour::WinnerDetected => message
        puts "Hurray winner detected"
        puts message
        break
      end
    end
  end
end
