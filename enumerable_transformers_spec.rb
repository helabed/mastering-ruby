require 'securerandom'
require 'set'
require 'active_support/all'


describe 'Enumerable transformers' do
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
  context '- map' do
    items = %w(hello mello yello)
    it 'returns the transformed collection for which the block is applied to each element of original collection' do
      result = items.map do |x|
        x + 'w'
      end
      expect(result).to eq ['hellow', 'mellow', 'yellow']
    end
  end
  context '- collect (same as map)' do
    items = %w(hello mello yello)
    it 'returns the transformed collection for which the block is applied to each element of original collection' do
      result = items.collect do |x|
        x + 'w'
      end
      expect(result).to eq ['hellow', 'mellow', 'yellow']
    end
  end
  context '- partition (same as [select(&block), reject(&block)])' do
    items = %w(hello mello yellow)
    it 'returns 2 arrays for which all items in the collection whose blocks evaluate to true and false, respectively' do
      result = items.partition do |x|
        x.end_with?('llow')
      end
      expect(result).to eq [['yellow'], ['hello', 'mello']]
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
  context '- sort' do
    items = %w(yello mello hello)
    it 'returns the transformed sorted collection by the given block or the elements own <=> operator' do
      result = items.sort do |x, y|
        x <=> y
      end
      expect(result).to eq ['hello', 'mello', 'yello']
    end
  end
  context '- sort_by' do
    it 'returns sorted collection using criteria in given block' do
      result = %w{ apple pear fig }.sort_by {|word| word.length}
      expect(result).to eq ['fig', 'pear', 'apple']
    end
  end
  context 'reduce - same as inject' do
    it 'reduces an array with the help of some binary operation or block' do
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
  context 'sort an array with reduce/inject - and in-order insert into new array' do
    it 'sorts a literal array by reducing it and in-order inserting it into new array' do
      array = [3,4,2,11,2,5,3]
      array_copy = array.dup
      sorted_array = array.inject([]) do |arr, e|
        smallest = array_copy.inject do |min, x|
          min < x ? min : x
        end
        #sleep 0.25
        #puts "original: #{array_copy}"
        array_copy.delete_at(array_copy.find_index(smallest))
        arr << smallest
        #puts "sorted: #{arr}"
        arr
      end
      expect(sorted_array).to eq [2,2,3,3,4,5,11]
    end
    it 'sorts a random array by reducing it and in-order inserting it into new array' do
      total_num_of_items = 13
      randomness_range = 10
      rand_array = Array.new(total_num_of_items) { SecureRandom.random_number(randomness_range) }
      ruby_sorted_array = rand_array.sort_by { |w| w }

      array = rand_array
      array_copy = array.dup
      sorted_array = array.inject([]) do |arr, e|
        smallest = array_copy.inject do |min, x|
          min < x ? min : x
        end
        array_copy.delete_at(array_copy.find_index(smallest))
        arr << smallest
        arr
      end
      expect(sorted_array).to eq ruby_sorted_array
    end
  end
  context 'sort an array with looping and swapping - i.e a bubble sort' do
    it 'sorts a literal array with a bubble sort' do
      array = [3,4,2,11,2,5,3]
      loop do
        if array.length <= 1
          break # array already sorted
        end
        swapping_occurred = false

        (array.length-1).times do |i|
          if array[i] > array[i+1]
            array[i+1], array[i] = array[i], array[i+1]
            #sleep 0.25
            swapping_occurred = true
          end
          #puts "iteration #{i}, array: #{array}"
        end

        #puts "array: #{array}"
        break if swapping_occurred == false
      end
      expect(array).to eq [2,2,3,3,4,5,11]
    end
    it 'sorts a random array with a bubble sort' do
      total_num_of_items = 13
      randomness_range = 10
      rand_array = Array.new(total_num_of_items) { SecureRandom.random_number(randomness_range) }
      ruby_sorted_array = rand_array.sort_by { |w| w }
      array = rand_array
      loop do
        if array.length <= 1
          break # array already sorted
        end
        swapping_occurred = false

        (array.length-1).times do |i|
          if array[i] > array[i+1]
            array[i+1], array[i] = array[i], array[i+1]
            #sleep 1
            swapping_occurred = true
          end
          #puts "iteration #{i}, array: #{array}"
        end

        #puts "array: #{array}"
        break if swapping_occurred == false
      end
      expect(array).to eq ruby_sorted_array
    end
  end
  context 'Factorials' do
    def factorial(n)
      return 0 if n == 0
      return 1 if n == 1
      n * factorial(n-1)
    end
    it 'calculate a factorial' do
      n = 4
      expect(factorial(0)).to eq 0
      expect(factorial(1)).to eq 1
      expect(factorial(2)).to eq 2
      expect(factorial(3)).to eq 6
      expect(factorial(4)).to eq 24
    end
  end
  context 'use Set to remove duplicates from Array' do
    def remove_dups(arr)
      s = Set.new
      arr.each do |e|
        s << e
      end
      s.to_a
    end
    it 'removes dups using Set' do
      array = [3,4,2,11,2,5,3]
      expect(remove_dups(array)).to eq [3,4,2,11,5]
    end
  end
  context 'use binary search to find element in Array' do
    def is_element_in_array?(el, arr)
      return false if (arr == nil || arr.size == 0)
      return false if (arr.size == 1 && arr[0] != el)
      sorted_arr = arr.sort
      left_half, right_half = sorted_arr.in_groups(2)
      left = left_half
      right = right_half.compact
      #puts "left_half: #{left}"
      #puts "right_half: #{right}"
      if el < left.last
        # descend left
        is_element_in_array?(el, left)
      elsif el == left.last
        # element found
        return true
      elsif el > right.first
        # descend right
        is_element_in_array?(el, right)
      elsif el == right.first
        # element found
        return true
      else
        return false # not in array
      end
    end
    it 'finds an element in array using binary search' do
      array = [3,4,2,11,2,5,3]
      in_array = is_element_in_array?(1, array)
      expect(is_element_in_array?(3, array)).to eq true
      expect(is_element_in_array?(4, array)).to eq true
      expect(is_element_in_array?(2, array)).to eq true
      expect(is_element_in_array?(5, array)).to eq true
      expect(is_element_in_array?(11, array)).to eq true
      expect(is_element_in_array?(1, array)).to eq false
    end
  end
end



RSpec.describe 'Enumerables' do
  before(:each) do
    @arr = [1,2,3]
  end

  it 'each should produce every element of the array' do
    expect(
      @arr.each {|e| e}
    ).to eq [1,2,3]
  end

  it 'Enumerator created from each without a block' do
    expect((@arr.each).class).to be Enumerator
  end

  it 'Enumerator allows chaining multiple enumerators' do
    expect(@arr.map.with_index {|e,i| "element: #{e} is at index: #{i}"}).to eq [
      "element: 1 is at index: 0",
      "element: 2 is at index: 1",
      "element: 3 is at index: 2"]
  end

  context 'when inlcuded in a class, Enumerator can augment its behavior' do
    before(:each) do
      @ll = LinkedList.new
      @ll.insert(5)
      @ll.insert(6)
      @ll.insert(7)
      @ll.insert(8)
      @ll.inspect
    end

    it 'should return all elements the list when traversed' do
      array = []
      @ll.traverse do |data|
        array << data
      end
      expect(array).to eq [5,6,7,8]
    end
  end
end

class LinkedList
  attr_accessor :head

  def traverse(&block)
    locator = @head
    block.call(locator.node.data)
    while locator.next != nil
      locator = locator.next
      block.call(locator.node.data)
    end
  end

  def insert(val)
    if @head == nil
      @head = List.new(val)
      return
    end
    locator = @head
    while locator.next != nil
      locator = locator.next
    end
    locator.next = List.new(val)
  end

  def inspect
    locator = @head
    puts ""
    while locator != nil
      puts "node: #{locator.node.data}, next: #{locator.next}"
      locator = locator.next
    end
  end

  class Node
    attr_accessor :data

    def initialize(val)
      @data = val
    end
  end

  class List
    attr_accessor :next
    attr_accessor :node

    def initialize(val)
      @node = Node.new(val)
      @next = nil
    end
  end
end
