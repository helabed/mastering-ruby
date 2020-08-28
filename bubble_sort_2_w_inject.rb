# require 'rspec/autorun'
# require 'algorithms'
#   include Algorithms
# require 'active_support/all'
# The above statements are useful when running in
# coderpad.io/sandbox
require 'securerandom'
require 'set'

RSpec.describe 'BubbleSort testing iteration 2' do
  it 'should sort any array' do
    3.times do
      bs = BubbleSort.new

      n = 7
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
  LOG_LEVEL_NONE  = false
  LOG_LEVEL = LOG_LEVEL_DEBUG

  def debugging
    LOG_LEVEL == LOG_LEVEL_DEBUG
  end

  def info
    LOG_LEVEL == LOG_LEVEL_INFO
  end

  def quiet
    LOG_LEVEL == LOG_LEVEL_NONE
  end

  def log(msg, label='')
    if debugging
      print "-"*20
      print label
      print "-"*20
      print "\n"
      print "#{msg}\n"
    end
  end
  def print_success(rand_array, sorted_array, bubble_sorted_array)
    if bubble_sorted_array == sorted_array
      if debugging
        log "#{rand_array} ->  #{bubble_sorted_array}", "sorted array"
        puts ""
        puts "SUCCESS."
        puts ""
        puts ""
        puts ""
        sleep 5
      elsif info
        puts "#{rand_array} ->  #{bubble_sorted_array}"
      elsif quiet
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

  def sort_w_array_only(ar)
    i = 0
    sorted = []
    for el in ar do
      log el, "element at location #{i}" if debugging
      sleep 0.1
      i += 1

      if sorted.size == 0
        sorted << el
        next
      elsif sorted.size == 1
        sorted = swap(sorted[0],el)
        next
      end
      log sorted, 'sorted' if debugging
      element_inserted = false
      sorted.dup.each_with_index do |item, index|
        log "#{item} ->  #{sorted}", "sorted[#{index}] on element #{el}" if debugging

        if el < item
          log "inside if before inserting #{el}" if debugging
          sorted.insert(index, el)
          log sorted, 'sorted' if debugging
          element_inserted = true
          break
        end
      end
      unless element_inserted
        log "before pushing #{el}" if debugging
        sorted.push(el)
      end
    end

    return sorted
  end

  def sort(ar)
    #sort_w_array_only(ar)
    #sort_w_ruby(ar)
    sort_w_inject(ar)
  end

  def sort_w_ruby(ar)
    ar.sort
  end

  def sort_w_inject(array)
    i = 0
    array.inject([]) do |ar, val|
      log i, 'i'
      log ar, "injected_array"
      log val, "injected_val"
      puts '' if debugging
      puts '' if debugging
      if ar.size > 0
        if ar[i-1] <= val
          ar << val
        elsif ar[i-1] > val
          # doing injected_array traversal and inserting val
          # on an array that is already sorted - i.e in-order insert
          log "doing in-order insert for #{val}", "injected array traversal"
          ar.dup.each_with_index do |item, index|
            print "#{item} -> " if debugging
            if val <= item
              ar.insert(index, val)
              puts "" if debugging
              break
            end
          end
          # doing single pair swap - was not enough
          # comparing last value of injected_array and swapping
          # it with injected_val is not correct
          #tmp = ar[i-1]
          #ar[i-1] = val
          #ar << tmp
        end
      else
        ar << val
      end
      i += 1
      ar
    end
  end
end
