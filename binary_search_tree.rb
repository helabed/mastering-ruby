##comment out these 3 lines for standlone RSpec (i.e when NOT in coderpad)
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


RSpec.describe 'BinarySearchTree (BST) testing iteration 1' do
  it 'should search for an element stored in BST' do
    total_num_of_items = 9
    randomness_range = 100
    edge = [
      Array.new(total_num_of_items) { SecureRandom.random_number(randomness_range) },
#     [1,2,2,3,3,33,113],
#     [0,0,2,113,3],
    ]

    aggregate_failures "aggregate array for #{edge.size} arrays" do
      edge.each do |rand_array|

        item_to_search_for = SecureRandom.random_number(randomness_range)

        rand_array << item_to_search_for # adds it because we want to search for it
        rand_array.shuffle!

        puts ""
        puts ""
        bs = BinarySearchTree.new
        # overriding above array for quick testing setup
        #rand_array = [30, 92, 36, 66, 33, 63]
        #item_to_search_for = 36
        #rand_array = [54, 93, 94, 10, 54, 40]  # different lines for level 3
        #item_to_search_for = 10
        #rand_array = [20, 95, 52, 12, 71, 4]  # different lines for level 3
        #item_to_search_for = 12
        #rand_array = [40, 59, 4, 98, 98, 51, 15, 83, 92, 3, 19] # one array both lines
        #rand_array << [55, 25, 38, 65, 60, 42, 31, 36, 76, 38, 81, 64, 16, 47, 22]
        #item_to_search_for = 42

        rand_array = [90, 68, 93, 73, 40, 30, 47, 22, 5, 9]
        item_to_search_for = 73
        bs.log rand_array, 'the array'
        bs.log item_to_search_for, 'Will be searching for'
        bs.insert_into(rand_array)
        bs.display_tree
        bs.search_for(rand_array, item_to_search_for)
      end
    end
  end
end

class BinarySearchTree
  LOG_LEVEL_DEBUG = 2
  LOG_LEVEL_INFO  = 1
  LOG_LEVEL_NONE  = false
  LOG_LEVEL = LOG_LEVEL_DEBUG

  def debugging; LOG_LEVEL == LOG_LEVEL_DEBUG; end
  def info;      LOG_LEVEL == LOG_LEVEL_INFO;  end
  def quiet;     LOG_LEVEL == LOG_LEVEL_NONE;  end

  def log(msg, label='')
    if debugging
      print "-"*20; print label; print "-"*20; print "\n"; print "#{msg}\n" if msg
    end
  end

  attr_accessor :root_tree

  def initialize
    if @root_tree == nil
      @root_tree = Tree.new
      @root_tree.height = 1
      @root_tree.indent = 23
      @root_tree.parent = nil
      log "", "Root Tree created #{@root_tree.display_tree}" if debugging
    end
  end

  def insert(node)
    @root_tree.insert_element(node)
  end

  def insert_into(arr)
    puts "" if debugging
    log arr, "Inserting Array Elements into BST" if debugging
    arr.each do |el|
      log nil, "Inserting Element #{el} into BST" if debugging
      insert(Node.new(el))
    end
  end

  def search_for(arr,val)
    log arr, "Finished Adding array -> BST"
    log '', "Searching BST for -> #{val}"
  end

  def bst_search(ar, val)
  end

  def display_tree
    if @root_tree && (debugging || info)
      log nil, "Displaying Tree"
      puts "#{' '*(@root_tree.indent)}RT(#{@root_tree.node.display_node})"
      @root_tree.display
    end
  end

  #
  #
  # BinarySearchTree::Node
  #
  class Node
    attr_accessor :data

    def debugging; LOG_LEVEL == LOG_LEVEL_DEBUG; end

    def initialize(data)
      @data = data
      puts "Node created with data #{data}" if debugging
    end

    def display
      puts "Displaying Node with #{data}"
    end

    def display_node
      "#{data}"
    end

    def to_s
      s = ''
      s << "\nhash: #{(self.hash % 1000)}"
      s << "\ndata: #{self.data}"
      s << "\n"
      return s
    end

    def dispose
      @data = nil
    end
  end
  # End of BinarySearchTree::Node

  #
  #
  # BinarySearchTree::Tree
  #
  class Tree
    DISPLAY_SHIFT = 5
    attr_accessor :node
    attr_accessor :left_child
    attr_accessor :right_child
    attr_accessor :parent
    attr_accessor :height
    attr_accessor :indent

   def debugging; LOG_LEVEL == LOG_LEVEL_DEBUG; end

    def initialize
      @node = nil
      @left_child = nil
      @right_child = nil
      @parent = nil
      @height = nil
      @indent = nil
    end

    def display_tree
      "w/hash: #{(self.hash % 1000)}"
    end

    def display
      if @left_child && @right_child
        print "#{' '*@left_child.indent}L#{left_child.height}"+
          "(#{left_child.node.display_node})"
        approx_left_node_text_width = 6
        corrected_indentation = @right_child.indent -
                                @left_child.indent -
                                approx_left_node_text_width
        corrected_indentation < 0 ? 0 : corrected_indentation
        print "#{' '*corrected_indentation}R#{right_child.height}"+
          "(#{right_child.node.display_node})\n"
        @left_child.display
        @right_child.display
      elsif @left_child && @right_child == nil
        non_neg_indent = (@left_child.indent < 0 ? 0 : @left_child.indent)
        puts "#{' '*non_neg_indent}L#{left_child.height}"+
          "(#{left_child.node.display_node})"
        @left_child.display
      elsif @left_child == nil && @right_child
        puts "#{' '*@right_child.indent}R#{right_child.height}"+
          "(#{right_child.node.display_node})"
        @right_child.display
      end
    end

    def to_s
      s = ''
      s << "\nhash: #{(self.hash % 1000)}"
      s << "\nheight: #{self.height}"
      s << "\nindent: #{self.indent}"
      s << "\nparent: "; if self.parent then "#{self.parent.node}" end
      s << "\nnode: #{self.node}"
      s << "\nleft_child: "; if self.left_child then "#{self.left_child}" end
      s << "\nright_child: "; if self.right_child then "#{self.right_child}" end
      s << "\n"
      return s
    end

    def insert_element(node)
      if @node == nil
        @node = node
        if debugging
          puts "Tree at height #{self.height} inserted node #{node.display_node} into BST"
        end
      elsif node.data < @node.data
        if @left_child == nil
          @left_child = Tree.new
          @left_child.parent = self
          @left_child.height = self.height + 1 if self.height
          @left_child.indent = self.indent - DISPLAY_SHIFT if self.indent
        end
        @left_child.insert_element(node)
        if debugging
          puts "  Tree w/node #{self.node.display_node} at height #{self.height} "+
               "was traversed-left towards node #{@left_child.node.display_node}"
        end
      elsif node.data > @node.data
        if @right_child == nil
          @right_child =Tree.new
          @right_child.parent = self
          @right_child.height = self.height + 1 if self.height
          @right_child.indent = self.indent + DISPLAY_SHIFT if self.indent
        end
        @right_child.insert_element(node)
        if debugging
          puts "  Tree w/node #{self.node.display_node} at height #{self.height} "+
               "was traversed-right towards node #{@right_child.node.display_node}"
        end
      else
        if debugging
          puts "Node #{node.display_node} is already in tree - ignoring"
        end
      end
    end

    def delete_element(root, node)
    end

    def dispose
      @node.dispose        if @node
      @left_child.dispose  if @left_child
      @right_child.dispose if @right_child
    end
  end
  # End of BinarySearchTree::Tree
end
