# require 'rspec/autorun'
# require 'algorithms'
#   include Algorithms
# require 'active_support/all'
# The above statements are useful when running in
# coderpad.io/sandbox
require 'securerandom'
require 'set'

RSpec.describe 'BinarySearch testing iteration 1' do
  it 'should search for an element on all edge conditions arrays' do
    total_num_of_items = 100
    randomness_range =  1000
    edge = [
      Array.new(total_num_of_items) { SecureRandom.random_number(randomness_range) },
#     [1,2,2,3,3,33,113],
#     [0,0,2,113,3],
#     [0,1,3,113,3],
#     [1,90,1131,2,0],
#     [2,3,113,3,3],
#     [2,113,0,1,3]
    ]

    aggregate_failures "aggregate array for #{edge.size} arrays" do
      edge.each do |rand_array|
        bs = BinarySearch.new

        item_to_search_for = SecureRandom.random_number(randomness_range)

        rand_array << item_to_search_for # adds it because we want to search for it
        rand_array.uniq!
        sorted_array = rand_array.sort_by { |w| w }


        puts ""
        puts ""
        bs.log item_to_search_for, 'Search for this'
        bs.log sorted_array, 'the array'
        binary_search_result = bs.search_for(sorted_array, item_to_search_for)
        expect(binary_search_result).to eq(item_to_search_for)
      end
    end
  end
end

class BinarySearch
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
  def print_success(item_to_search_for, binary_search_result)
    if binary_search_result == item_to_search_for
      if debugging
        log "#{item_to_search_for} ->  #{binary_search_result}", "Item found"
        puts ""
        puts "SUCCESS."
        puts ""
        puts ""
        puts ""
        sleep 5
      elsif info
        puts "#{item_to_search_for} ->  #{binary_search_result}"
      elsif quiet
        print '.'
      end
    end
  end

  def search_for(arr,val)
    # return val
    # return ruby_search(arr, val)
    # return ruby_search_w_log(arr, val)
    # return linear_search_w_array_only(arr, val)
    return binary_search_w_array(arr, val)
  end

  def ruby_search(ar, val)
    ar.find {|e| e == val}
  end

  def ruby_search_w_log(ar, val)
    ar.find do |e|
      lambda {sleep 1; print "#{e}."}.call if debugging
      e == val
    end
  end

  def linear_search_w_array_only(ar, val)
    i = 0
    found_it = false
    for el in ar do
      log el, "element at location #{i}" if debugging
      sleep 0.1 if debugging
      i += 1

      if el == val
        found_it = el
        break
      end
    end

    return found_it
  end

  def log_tree(right, left)
    if debugging
      print "left half"
      print "-"*20
      print "\n"
      print "#{right}\n"

      print " "*20
      print "right half"
      print "-"*20
      print "\n"
      print " "*20
      print "#{left}\n"
    end
  end

  def binary_search_w_array(ar, val)
    puts "" if debugging
    log "", "splitting array for -> #{val} " if debugging
    left_half, right_half = ar.in_groups(2)
    log_tree left_half, right_half if debugging
    found_it = nil
    unless found_it
      if    val === left_half.first  then found_it = left_half.first
      elsif val === left_half.last   then found_it = left_half.last
      elsif val === right_half.first then found_it = right_half.first
      elsif val === right_half.last  then found_it = right_half.last
      elsif val < left_half.last
        sleep 1 if debugging
        puts "" if debugging
        puts "using left half" if debugging
        found_it = binary_search_w_array(left_half, val)
      elsif val > right_half.first
        sleep 1 if debugging
        puts "" if debugging
        puts "using right half" if debugging
        found_it = binary_search_w_array(right_half, val)
      end
    end
    puts "found it! #{found_it}" if debugging
    return found_it
  end
end


# since method Array.in_groups(n) is in active_support and not in Ruby
# I am opening Array and adding it.
class Array
  def in_groups(num_groups)
    return [] if num_groups == 0
    slice_size = (self.size/Float(num_groups)).ceil
    groups = self.each_slice(slice_size).to_a
    return groups
  end
end
