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



RSpec.describe 'Strings' do
  before(:all) do
    @string_array = ["Javascript advanced100%",
      "Ruby on Rails 6.x Enterprise Edition80%",
      "Angular JS 1.x75%"
    ]
    @string_text = <<-TEXT
      Javascript advanced100%
      Ruby on Rails 6.x Enterprise Edition80%
      Angular JS 1.x75%
    TEXT
  end
  context 'scan - to get an array of matches on a String using Regex' do
    def string_parser string_array
      transformed_array = []
      string_array.each do |e|
        transformed_array << e.scan(/\d+/).last.to_i
      end
      transformed_array
    end
    it 'can scan the string to extract the desired Regex pattern (percentages in this case)' do
      expect(string_parser(@string_array)).to eq [100, 80, 75]
    end
  end
  context 'each_line - to get an array of string lines from a text document' do
    def string_lines string_text
      transformed_array = []
      string_text.each_line do |e|
        transformed_array << e.scan(/\d+/).last.to_i
      end
      transformed_array
    end
    it 'can scan the string to extract the desired Regex pattern (percentages in this case)' do
      expect(string_lines(@string_text)).to eq [100, 80, 75]
    end
  end
  context 'gsub & gsub! - to replace part of a string when pattern matches' do
    it 'can replace the substring with new content' do
      expect('Ruby on Rails'.gsub('R','T')).to eq 'Tuby on Tails'
    end
    it 'can replace the substring with new content using Regex' do
      expect('Ruby on Rails'.gsub(/^R/, 'T')).to eq 'Tuby on Rails'
    end
  end
end
