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
      #[1,2,2,3,3,33,113],
      #[0,0,2,113,3],
    ]

    aggregate_failures "aggregate array for #{edge.size} arrays" do
      edge.each do |rand_array|

        item_to_search_for = SecureRandom.random_number(randomness_range)

        rand_array << item_to_search_for # adds it because we want to search for it
        rand_array.shuffle!

        puts ""
        puts ""
        bst = BinarySearchTree.new
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
        #rand_array = [90, 68, 93, 73, 40, 30, 47, 22, 5, 9]
        #item_to_search_for = 73
        #rand_array = [45, 78, 42, 97, 34, 61, 53, 47, 72, 92]
        #item_to_search_for = 45

        #rand_array = [84, 49, 46, 39, 63, 5, 0, 84, 62, 26]
        #item_to_search_for = 84

        bst.log rand_array, 'the array'
        bst.log item_to_search_for, 'Will be searching for'
        bst.insert_into(rand_array)
        bst.display_tree
        found, data = bst.search_for(rand_array, item_to_search_for)
        expect(found).to be true
        expect(data).to eq item_to_search_for
        outcome = bst.delete_from(item_to_search_for)
        expect(outcome).to be true
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

  # search BST for element with 'val'in the BST
  #   original 'arr' provided just for logging/debugging
  def search_for(arr,val)
    if @root_tree
      if debugging || info
        log arr, "Finished Adding array -> BST"
        log '', "Searching BST for -> #{val}"
      end
      found, locator, parent = @root_tree.bst_search(@root_tree, Node.new(val))
      if debugging || info
        if found
          log parent, "Found 'parent' #{parent.node.data} in BST" if (parent && parent.node)
          log locator, "Found 'locator(sub-tree)' for #{locator.node.data}"
        else
          log '', "Did NOT find #{val} in the BST"
        end
      end
      return found, locator.node.data if found
      return found, nil if !found
    end
  end

  # delete element with 'value' from the BST
  def delete_from(value)
    log '', "Attempting to delete #{value} from BST"
    outcome = @root_tree.delete_element(@root_tree, Node.new(value))
    display_tree
    return outcome
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

    def dispose
      @data = nil
    end

    def display
      puts "Displaying Node with #{data}"
    end

    def display_node
      "#{data}"
    end

    def to_s
      s = ''
      s << "\n  hash: #{(self.hash % 1000)}"
      s << "\n  data: #{self.data}"
      s << "\n  --"
      return s
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

    def dispose
      @node.dispose        if @node
      @left_child.dispose  if @left_child
      @right_child.dispose if @right_child
    end

    def to_s
      s = ''
      s << "\nhash: #{(self.hash % 1000)}"
      s << "\nheight: #{self.height}"
      s << "\nindent: #{self.indent}"
      parent = self.parent.node.display_node if self.parent
      parent ||= 'nil'
      s << "\nparent: #{parent}"
      s << "\nnode: #{self.node.display_node}" if self.node
      if self.left_child && self.left_child.node
        left_child_node = self.left_child.node.display_node
      end
      s << "\nleft_child: #{left_child_node}"
      if self.right_child && self.right_child.node
        right_child_node = self.right_child.node.display_node
      end
      s << "\nright_child: #{right_child_node}"
      s << "\n"
      return s
    end

    def display_tree
      "w/hash: #{(self.hash % 1000)}"
    end

    def display
      if @left_child && @right_child
        non_neg_indent = (@left_child.indent < 0 ? 0 : @left_child.indent)
        print "#{' '*non_neg_indent}L#{left_child.height}"+
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
          @left_child.height = self.height + 1              if self.height
          @left_child.indent = self.indent - DISPLAY_SHIFT  if self.indent
        end
        @left_child.insert_element(node)
        if debugging
          puts "  Tree w/node #{self.node.display_node} at height #{self.height} "+
               "was traversed-left towards node #{@left_child.node.display_node}"
        end
      elsif node.data > @node.data
        if @right_child == nil
          @right_child = Tree.new
          @right_child.parent = self
          @right_child.height = self.height + 1              if self.height
          @right_child.indent = self.indent + DISPLAY_SHIFT  if self.indent
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

    # search for 'node' element in 'tree' sub-tree
    #
    # iterative implementation of binary search tree - search
    def bst_search(tree, node)
      locator = tree
      parent = nil
      found = false
      while( !found && locator)
        if node.data < locator.node.data
          # descend left
          parent = locator
          locator = locator.left_child
        elsif node.data > locator.node.data
          # descend right
          parent = locator
          locator = locator.right_child
        else
          found = true
        end
      end
      return found, locator, parent
    end

    # delete 'item' element from 'tree' sub-tree
    #
    # iterative implementation of binary search tree - delete
    # Ref: Advanced Programming in Pascal w/Data Structures(1988)
    #      Larry Nyhoff & Sanford Leestma (pages 466-471)
    # variable names matches thoes in book (as much as possible)
    def delete_element(tree, item)
      x           = nil # sub-tree object containing node to be deleted
      x_successor = nil # sub-tree object - in-order successor to x (or predecessor)
      parent      = nil # sub-tree object - parent of x, or soon its successor
      subtree     = nil # sub-tree object - subtree of x before deletion
      found       = false

      found, x, parent = bst_search(tree, item)

      puts "Elemeent to be deleted was found: #{found}"
      puts "Sub-tree whose node has to be deleted: #{x}"
      puts "Parent of sub-tree whose node has to be deleted: #{parent}"
      puts

      return false if ! found  # no point in going further

      if x.left_child && x.right_child
        # item to be deleted has 2 children
        # find in-order successor (predecessor) and its parent
        # to do so as per book page 469 - start with right child of x
        # and descend left as far as possible
        x_successor = x.right_child
        parent      = x
        while x_successor.left_child   # descending left until last left
          parent      = x_successor
          x_successor = x_successor.left_child
        end

        # move content of x_successor to x, and change x to point
        # to x_successor - which will be deleted after swap
        x.node.data = x_successor.node.data
        x = x_successor
      end

      # now proceed with case a if we had 0 or 1 child - book p. 466
      subtree = x.left_child
      subtree ||= x.right_child  # if left child is nil, use right child

      if parent == nil
        # root is being deleted, the subtree becomes root
        tree = subtree  # not sure if this is meaningful - changing a method argument param
      elsif parent.left_child == x
        parent.left_child = subtree
      else
        parent.right_child = subtree
      end

      x.right_child = nil
      x.left_child = nil
      #x.dispose
      return true # upon success ??
    end
  end
  # End of BinarySearchTree::Tree
end