# require 'rspec/autorun'
# require 'algorithms'
# include Algorithms
require 'securerandom'
#require 'active_support/all'
require 'set'

RSpec.describe 'BubbleSort testing iteration 1' do
  it 'should sort any array' do
    3.times do
      bs = BubbleSort.new

      n = 20
      rand_array = Array.new(n) { SecureRandom.random_number(n) }
      sorted_array = rand_array.sort_by { |w| w }

      bs.log rand_array, 'random array'
      bubble_sorted_array = bs.sort(rand_array)
      expect(bubble_sorted_array).to eq(sorted_array)
      bs.print_success(rand_array, sorted_array, bubble_sorted_array)
    end
  end
  it 'should sort all edge conditions arrays' do
    edge = [
      [1,2,2,3],
      [0,0,2,3],
      [0,1,3,3],
      [2,0,1,3],
      [1,1,2,0],
      [2,3,3,3],
      [2,0,1,3]
    ]

    aggregate_failures "aggregate array for #{edge.size} arrays" do
      edge.each do |rand_array|
        bs = BubbleSort.new

        sorted_array = rand_array.sort_by { |w| w }

        bs.log rand_array, 'the array'
        bubble_sorted_array = bs.sort(rand_array)
        expect(bubble_sorted_array).to eq(sorted_array)
        bs.print_success(rand_array, sorted_array, bubble_sorted_array)
      end
    end
  end
end

class BubbleSort
  LOG_LEVEL_DEBUG = 2
  LOG_LEVEL_INFO  = 1
  LOG_LEVEL_NONE  = 0
  LOG_LEVEL = LOG_LEVEL_INFO

  def log(msg, label='')
    if LOG_LEVEL == LOG_LEVEL_DEBUG
      print "-"*20
      print label
      print "-"*20
      print "\n"
      print "#{msg}\n"
    end
  end
  def print_success(rand_array, sorted_array, bubble_sorted_array)
    if bubble_sorted_array == sorted_array
      if LOG_LEVEL == LOG_LEVEL_DEBUG
        log "#{rand_array} ->  #{bubble_sorted_array}", "sorted array"
        puts ""
        puts "SUCCESS."
        puts ""
        puts ""
        puts ""
        sleep 5
      elsif LOG_LEVEL == LOG_LEVEL_INFO
        puts "#{rand_array} ->  #{bubble_sorted_array}"
      elsif LOG_LEVEL == LOG_LEVEL_NONE
        print '.'
      end
    end
  end

  def swap(a,b)
    if a < b
      return a,b
    else
      return b,a
    end
  end

  def sort(ar)
    i = 0
    sorted = []
    for el in ar do
      log el, "element at location #{i}" if LOG_LEVEL
      sleep 0.1
      i += 1

      if sorted.size == 0
        sorted << el
        next
      elsif sorted.size == 1
        sorted = swap(sorted[0],el)
        next
      end
      log sorted, 'sorted' if LOG_LEVEL
      element_inserted = false
      sorted.dup.each_with_index do |item, index|
        log "#{item} ->  #{sorted}", "sorted[#{index}] on element #{el}" if LOG_LEVEL

        if el < item
          log "inside if before inserting #{el}" if LOG_LEVEL
          sorted.insert(index, el)
          log sorted, 'sorted' if LOG_LEVEL
          element_inserted = true
          break
        end
      end
      unless element_inserted
        log "before pushing #{el}" if LOG_LEVEL
        sorted.push(el)
      end
    end

    return sorted
  end
end
