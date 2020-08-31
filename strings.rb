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
  context 'strip & strip! - to trim leading or trailing white space' do
    it 'strips all white space in front and/or end of string' do
      expect('  Ruby on Rails     '.strip).to eq 'Ruby on Rails'
    end
  end
  context 'manually sorting a string' do
    def sort(s)
      sorted = []
      s.each_char do |c|
        sorted << c
      end
      sorted.sort.join('')
    end
    it 'manually sorts a string one char at a time by putting it in an array an sorting array' do
      expect(sort('64321')).to eq '12346'
    end
  end
  context 'removing duplicates words from a string' do
    it 'removes duplicate words from a string with help of arrays' do
      string_with_dups = 'this book is really really big'
      def remove_dups(string_with_dups)
        words = string_with_dups.split(' ')
        h = {}
        i = 1
        words.each do |w|
          h[w] = i
          i += 1
        end
        #puts "h.keys = #{h.keys}"
        #puts "h.values = #{h.values}"
        #puts "h= #{h}"
        #puts "h.to_a= #{h.to_a}"
        h.keys.join(' ')
      end
      expect(remove_dups(string_with_dups)).to eq 'this book is really big'
    end
    it 'removes duplicate words from a string with help of arrays - the safe way (no Hash FIFO assumptions)' do
      string_with_dups = 'this book is really really big'
      def remove_dups(string_with_dups)
        words = string_with_dups.split(' ')
        h = {}
        i = 1
        words.each do |w|
          h[w] = i
          i += 1
        end
        #puts "h.keys = #{h.keys}"
        #puts "h.values = #{h.values}"
        #puts "h= #{h}"
        #puts "h.to_a= #{h.to_a}"
        # we are using value of hash to sort to guarantee that the element of hash are sorted
        # in the order of values of each hash element when we inserted them.
        #puts "h.to_a.sort_by {|a,b| a[1] <=> b[1]} = #{h.to_a.sort_by {|a,b| a[1] <=> b[1]}}"
        # sort by value after converting hash to array of tupples, then sorting by 2nd element of these
        # sub arrays(2 element arrays - tupples), then mapping only the first elements of these tupples
        # then joining them.
        h.to_a.sort_by {|a,b| a[1] <=> b[1]}.map {|e| e[0]}.join(' ')
      end
      expect(remove_dups(string_with_dups)).to eq 'this book is really big'
    end
  end
end
