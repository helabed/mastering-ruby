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


RSpec.describe 'Hashes' do
  context 'removing duplicates words from a string' do
    it 'removes duplicate words from a string with help of arrays and hashes' do
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
    it 'removes duplicate words from a string with help of arrays/hashes - the safe way (no Hash FIFO assumptions)' do
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
  context 'Hash methods' do
    Hash_methods = <<-METHODS
      <=
      ==
      >
      >=
      []
      []=
      any?
      assoc
      clear
      compact
      compact!
      compare_by_identity
      compare_by_identity?
      default
      default=
      default_proc
      default_proc=
      delete
      delete_if
      dig
      each
      each_key
      each_pair
      each_value
      empty?
      eql?
      fetch
      fetch_values
      filter
      filter!
      flatten
      hash
      has_key?
      has_value?
      include?
      index
      indexes (<= v1_8_7_330)
      indices (<= v1_8_7_330)
      initialize_copy
      inspect
      invert
      keep_if
      key
      key?
      keys
      length
      member?
      merge
      merge!
      pretty_print
      pretty_print_cycle
      rassoc
      rehash
      reject
      reject!
      replace
      select
      select!
      shift
      size
      slice
      sort (<= v1_8_7_330)
      store
      to_a
      to_h
      to_hash
      to_proc
      to_s
      to_yaml (<= v1_9_1_378)
      transform_keys
      transform_keys!
      transform_values
      transform_values!
      update
      value?
      values
      values_at
      yaml_initialize (<= v1_9_1_378)

      Included modules
    METHODS
  end
end
