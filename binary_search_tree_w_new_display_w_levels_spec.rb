#comment out this line for standlone RSpec (i.e when NOT in coderpad)
require './binary_search_tree'
require 'rspec/autorun'
##The above statements are useful when running in
##coderpad.io/sandbox - otherwise comment out
require 'securerandom'
require 'set'
require 'active_support/all'
require 'pry'
#require 'byebug'

# you can run this file 25 times or more/less with this bash loop
# for i in {1..25}; do rspec binary_search_tree_w_new_display_w_levels.rb; done

RSpec.describe 'BinarySearchTree (BST) testing - iteration last' do
  it 'should search for an element stored in BST' do
    total_num_of_items = 15
    randomness_range = 100
    edge = [
      Array.new(total_num_of_items) { SecureRandom.random_number(randomness_range) },
    ]

    aggregate_failures "aggregate array for #{edge.size} arrays" do
      edge.each do |rand_array|
        item_to_search_for     = SecureRandom.random_number(randomness_range)
        item_to_traverse_from  = SecureRandom.random_number(randomness_range)
        item_to_delete         = SecureRandom.random_number(randomness_range)

        rand_array << item_to_search_for    # adds it because we want to search for it
        rand_array << item_to_traverse_from # adds it because we want to use it
        rand_array << item_to_delete        # adds it because we want to delete it
        rand_array.shuffle!

        puts ""
        bst = BinarySearchTree.new
        L = Logger

        # un-comment rand_array below to suit your needs
        # without adjustment, rand_array below demonstrate node/tree collision
        #rand_array = [8, 87, 69, 63, 18, 42, 29, 27, 28, 39, 49, 45, 58, 65, 72]
        # without adjustment, rand_array below demonstrate left edge overflow
        #rand_array = [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]

        # to display the maximum number of nodes with 2-digits, un-comment rand_array below
        #rand_array = (1..99).to_a.shuffle
        L.log rand_array, 'the array'
        bst.insert_into(rand_array)
        bst.display_tree
      end
    end
  end
end
