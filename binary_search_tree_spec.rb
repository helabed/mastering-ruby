#in coderpad.io/sandbox, copy file binary_search_tree.rb
#to the bottom of this file and comment out this
#require line below.
require './binary_search_tree'
#comment out this line below for standlone RSpec (i.e when NOT in coderpad)
require 'rspec/autorun'
##The above statements are useful when running in
##coderpad.io/sandbox - otherwise comment out
require 'securerandom'
require 'set'
require 'active_support/all'
require 'pry'
#require 'byebug'


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
        # to display the maximum number of nodes with 2-digits, un-comment rand_array below
        #rand_array = (1..99).to_a.shuffle

        puts ""
        puts ""
        bst = BinarySearchTree.new
        L = Logger

        L.log rand_array, 'the array'
        bst.insert_into(rand_array)
        bst.display_tree

        L.log item_to_search_for, 'Will be searching for'
        found, data = bst.search_for(rand_array, item_to_search_for)
        expect(found).to be true
        expect(data).to eq item_to_search_for

        height = bst.height_of_tree
        expect(height).to be < 30 # random high number

        L.log item_to_delete, 'Will be deleting'
        bst.display_tree
        outcome = bst.delete_from(item_to_delete)
        expect(outcome).to be true

        bst.do_right_to_left_leaf_traverse
        bst.do_in_order_traverse
        bst.do_pre_in_order_traverse
        bst.do_post_in_order_traverse

        bst.do_right_to_left_leaf_traverse
        outcome = bst.do_ancestors_traverse(item_to_traverse_from)
        expect(outcome).to be true

        outcome = bst.do_descendants_traverse(item_to_traverse_from)
        expect(outcome).to be true
        bst.display_tree
        L.log '', 'SUCCESS'
      end
    end
  end
end
