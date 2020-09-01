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
  context 'Array methods' do
    Array_methods = <<-METHODS
      https://ruby-doc.org/core-2.7.1/Array.html
      https://apidock.com/ruby/Array
      Array#methods:
        &        bsearch        difference        find_index    intersection  pretty_print          sample          sum             transpose
        *        bsearch_index  dig               first         join          pretty_print_cycle    second          take            union
        +        clear          drop              flatten       keep_if       product               second_to_last  take_while      uniq
        -        collect        drop_while        flatten!      last          push                  select          third           uniq!
        <<       collect!       each              forty_two     length        rassoc                select!         third_to_last   unshift
        <=>      combination    each_index        fourth        map           reject                shelljoin       to              values_at
        ==       compact        empty?            from          map!          reject!               shift           to_a            without
        []       compact!       eql?              hash          max           repeated_combination  shuffle         to_ary          zip
        []=      concat         excluding         in_groups     min           repeated_permutation  shuffle!        to_default_s    |
        all?     count          extract!          in_groups_of  minmax        replace               size            to_formatted_s
        any?     cycle          extract_options!  include?      none?         reverse               slice           to_h
        append   deconstruct    fetch             including     one?          reverse!              slice!          to_param
        as_json  deep_dup       fifth             index         pack          reverse_each          sort            to_query
        assoc    delete         fill              inquiry       permutation   rindex                sort!           to_s
        at       delete_at      filter            insert        pop           rotate                sort_by!        to_sentence
        blank?   delete_if      filter!           inspect       prepend       rotate!               split           to_xml
    METHODS
  end
  context 'Enumerable methods' do
    Enumerable_methods = <<-METHODS
      https://ruby-doc.org/core-2.7.1/Enumerable.html
      https://apidock.com/ruby/Enumerable
      Enumerable#methods:
        all?         collect         drop_while        entries     find_all    group_by    lazy     min        partition     slice_after   take        uniq
        any?         collect_concat  each_cons         exclude?    find_index  include?    many?    min_by     pluck         slice_before  take_while  without
        as_json      count           each_entry        excluding   first       including   map      minmax     reduce        slice_when    tally       zip
        chain        cycle           each_slice        filter      flat_map    index_by    max      minmax_by  reject        sort          to_a
        chunk        detect          each_with_index   filter_map  grep        index_with  max_by   none?      reverse_each  sort_by       to_h
        chunk_while  drop            each_with_object  find        grep_v      inject      member?  one?       select        sum           to_set
    METHODS
  end
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
  context 'each_slice(n) - to split an array into slices containing n elements' do
    it 'splits array into matching size with a default fill of nil' do
      sliced_enumerator = %w(1 2 3 4 5 6 7 8 9 10).each_slice(4)
      expect(sliced_enumerator.to_a).to eq [
        ["1", "2", "3", "4"],
        ["5", "6", "7", "8"],
        ["9", "10"]
      ]
    end
  end
  context 'reduce - same as inject' do
    it 'reduces an array with the help of some binary opeation or block' do
      # Sum some numbers
      expect((5..10).reduce(:+)).to eq 45
      # Same using a block and inject
      expect((5..10).inject { |sum, n| sum + n }).to eq 45
      # Multiply some numbers
      expect((5..10).reduce(1, :*)).to eq 151200
      # Same using a block
      expect((5..10).inject(1) { |product, n| product * n }).to eq 151200
      # find the longest word
      longest = %w{ cat sheep bear }.inject do |memo, word|
        memo.length > word.length ? memo : word
      end
      expect(longest).to eq 'sheep'
    end
  end
end
