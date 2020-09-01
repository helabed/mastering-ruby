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
      https://ruby-doc.org/core-2.7.1/Hash.html
      https://apidock.com/ruby/Hash
      Hash#methods:
        <                     deep_merge              each_pair             invert                           reverse_update   to_query
        <=                    deep_merge!             each_value            keep_if                          select           to_s
        ==                    deep_stringify_keys     empty?                key                              select!          to_xml
        >                     deep_stringify_keys!    eql?                  key?                             shift            transform_keys
        >=                    deep_symbolize_keys     except                keys                             size             transform_keys!
        []                    deep_symbolize_keys!    except!               length                           slice            transform_values
        []=                   deep_transform_keys     extract!              member?                          slice!           transform_values!
        any?                  deep_transform_keys!    extractable_options?  merge                            store            update
        as_json               deep_transform_values   fetch                 merge!                           stringify_keys   value?
        assert_valid_keys     deep_transform_values!  fetch_values          nested_under_indifferent_access  stringify_keys!  values
        assoc                 default                 filter                pretty_print                     symbolize_keys   values_at
        blank?                default=                filter!               pretty_print_cycle               symbolize_keys!  with_defaults
        clear                 default_proc            flatten               rassoc                           to_a             with_defaults!
        compact               default_proc=           has_key?              rehash                           to_h             with_indifferent_access
        compact!              delete                  has_value?            reject                           to_hash
        compare_by_identity   delete_if               hash                  reject!                          to_options
        compare_by_identity?  dig                     include?              replace                          to_options!
        deconstruct_keys      each                    index                 reverse_merge                    to_param
        deep_dup              each_key                inspect               reverse_merge!                   to_proc
    METHODS
  end
end
