###comment out these 3 lines for standlone RSpec (i.e when NOT in coderpad)
#require 'rspec/autorun'
#require 'algorithms'
#  include Algorithms
##The above statements are useful when running in
##coderpad.io/sandbox - otherwise comment out
require 'securerandom'
require 'set'
require 'active_support/all'
require 'pry'
require 'byebug'


RSpec.describe 'Arrays' do
  context 'in_groups - to split an array in almost same size arrays' do
    it 'splits array into matching size with a default fill of nil' do
      expect(%w(1 2 3 4 5 6 7 8 9 10).in_groups(3)).to eq [
        ["1", "2", "3", "4"],
        ["5", "6", "7", nil],
        ["8", "9", "10", nil]
      ]
    end
    it 'splits array into matching size with specified fill of h' do
      expect(%w(1 2 3 4 5 6 7 8 9 10).in_groups(3,'h')).to eq [
        ["1", "2", "3", "4"],
        ["5", "6", "7", 'h'],
        ["8", "9", "10", 'h']
      ]
    end
    it 'splits array into matching size with no fill' do
      expect(%w(1 2 3 4 5 6 7 8 9 10).in_groups(3,false)).to eq [
        ["1", "2", "3", "4"],
        ["5", "6", "7" ],
        ["8", "9", "10"]
      ]
    end
  end
end
