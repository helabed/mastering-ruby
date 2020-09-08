#comment out these 3 lines for standlone RSpec (i.e when NOT in coderpad)
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

        puts ""
        puts ""
        bst = BinarySearchTree.new

        # overriding above array/values in case we need to debug/fix failing test, or
        # for quick hard coded testing setup
        #rand_array = [30, 92, 36, 66, 33, 28, 63]
        #item_to_search_for = 30
        #item_to_traverse_from = 28
        #item_to_delete = 30
        #rand_array = [79, 11, 24, 89, 64, 80, 20, 80]
        #rand_array = [79, 11, 24, 89, 83, 25, 83, 82]
        #rand_array = [55, 10, 66, 27, 4, 2, 48, 37, 86, 71, 85, 90, 86, 60, 90, 17, 40, 14]
        #rand_array = [79, 11, 24, 89, 83, 25, 83, 82]
        #rand_array = [ 2, 79, 11, 24, 89, 83, 25, 83, 82]
        #rand_array = [ 99, 2, 79, 11, 24, 89, 83, 25, 83, 82]
        #rand_array = [75, 15, 14, 6, 0, 26, 27, 48, 46, 56, 49, 50, 54, 72, 95, 86, 82]


        # all arrays below have node collisons
        # rand_array = [40, 0, 10, 5, 23, 31, 28, 89, 64, 47, 45, 73, 75, 90, 92]
        # rand_array = [44, 4, 34, 10, 21, 18, 28, 31, 94, 78, 76, 50, 74, 55, 73, 77]
        # rand_array = [64, 36, 22, 5, 14, 11, 24, 61, 51, 44, 42, 53, 76, 70, 98, 82, 97]
        # rand_array = [70, 63, 32, 2, 15, 3, 16, 22, 25, 60, 83, 79, 80, 99, 90, 87]
        # rand_array = [45, 35, 14, 0, 23, 41, 76, 47, 58, 66, 59, 69, 77, 99, 87, 90]
        # rand_array = [52, 51, 44, 11, 4, 6, 27, 19, 15, 21, 43, 32, 39, 64, 72, 96, 92, 94]
        # rand_array = [48, 14, 9, 7, 13, 23, 31, 25, 46, 73, 69, 50, 72, 89, 81, 77, 85]
        # rand_array = [44, 20, 1, 0, 43, 25, 97, 83, 55, 45, 72, 59, 85, 84, 95]
        # rand_array = [52, 9, 6, 3, 8, 10, 36, 25, 33, 42, 41, 63, 61, 59, 92, 79, 77, 78]
        # rand_array = [16, 9, 8, 15, 83, 36, 27, 76, 59, 61, 66, 64, 81, 79, 82, 98, 93]
        # rand_array = [74, 8, 39, 22, 14, 37, 69, 47, 46, 41, 84, 81, 98, 87, 89]
        # rand_array = [74, 8, 39, 22, 37, 69, 47, 46, 41, 84, 81, 98, 87, 89]
        # rand_array = [82, 4, 75, 17, 50, 33, 66, 10, 49, 67, 52, 80, 58, 17, 15, 85, 3, 66]

        bst.log rand_array, 'the array'
        bst.insert_into(rand_array)
        bst.display_tree
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
  attr_accessor :random_array

  def initialize
    if @root_tree == nil
      @root_tree = Tree.new
      @root_tree.height = 1
      @root_tree.indent = ROOT_NODE_INDENT
      @root_tree.parent = nil
      log "", "Root Tree created #{@root_tree.tree_id}" if debugging
    end
  end

  def insert(node)
    @root_tree.insert_element(node)
  end

  def insert_into(arr)
    puts "" if debugging
    log arr, "Inserting Array Elements into BST" if debugging
    @random_array = arr
    arr.each do |el|
      puts "" if debugging || info
      log nil, "Inserting Element #{el} into BST" if debugging
      insert(Node.new(el))
      # to see elements being inserted
      display_tree if debugging || info
      sleep 0.25 if debugging || info
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
    outcome, new_root = @root_tree.delete_element(@root_tree, Node.new(value))
    @root_tree = new_root
    display_tree
    return outcome
  end

  def display_tree
    if @root_tree && (debugging || info)
      log nil, "Displaying Tree"
      TreeDisplayer.display_tree_2D(@root_tree)
      log @random_array, "The inserted array is:" if debugging
    end
  end

  def do_in_order_traverse
    if @root_tree && (debugging || info)
      log nil, "In Order Tree Traversal"
      @root_tree.show_me_in_order_traverse(@root_tree)
    end
  end

  def do_pre_in_order_traverse
    if @root_tree && (debugging || info)
      log nil, "Pre Order Tree Traversal"
      @root_tree.show_me_pre_order_traverse(@root_tree)
    end
  end

  def do_post_in_order_traverse
    if @root_tree && (debugging || info)
      log nil, "Post Order Tree Traversal"
      @root_tree.show_me_post_order_traverse(@root_tree)
    end
  end

  def height_of_tree
    if @root_tree
      height = @root_tree.height_of_tree
      if @root_tree && (debugging || info)
        log nil, "Computed Height of Tree is #{height}"
      end
      height
    end
  end

  def do_right_to_left_leaf_traverse
    if @root_tree && (debugging || info)
      log nil, "Right To Left Leaf Traversal"
      @root_tree.show_me_right_to_left_leaf_traverse(@root_tree)
    end
  end

  def do_ancestors_traverse(value)
    if debugging || info
      log nil, "Ancestors Traversal"
    end
    @root_tree.show_me_ancestors_traverse(@root_tree, Node.new(value))
  end

  def do_descendants_traverse(value)
    if debugging || info
      log nil, "Descendants Traversal"
    end
    @root_tree.show_me_descendants_traverse(@root_tree, Node.new(value))
  end

  #
  #
  # BinarySearchTree::Node
  #
  class Node
    attr_accessor :data
    attr_accessor :display_indent

    def debugging; LOG_LEVEL == LOG_LEVEL_DEBUG; end

    def initialize(data)
      @data = data
      @display_indent = 0
    end

    def dispose
      @data = nil
      @display_indent = 0
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
      s << "\n  display_indent: #{self.display_indent}"
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
    BinarySearchTree::ROOT_NODE_INDENT = 35
    INDENT_DECAY      = 2.10
    TREE_LIMB_INDENT  = 12 # keep this always even so that we can divide by 2
    NODE_DATA_SIZE    = 2
    NODE_DATA_PADDING = 1
    LEFT_NODE_INDENT  = 4
    RIGHT_NODE_INDENT = 4
    NUM_OF_DASHES = 8

    attr_accessor :node
    attr_accessor :left_child
    attr_accessor :right_child
    attr_accessor :parent
    attr_accessor :height
    attr_accessor :indent

   def debugging; LOG_LEVEL == LOG_LEVEL_DEBUG; end
   def info;      LOG_LEVEL == LOG_LEVEL_INFO;  end

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
      @parent.dispose      if @parent
    end

    def to_s
      s = ''
      s << "\nhash: #{(self.hash % 1000)}"
      s << "\nheight: #{self.height}"
      s << "\nindent: #{self.indent}"
      parent = self.parent.node.display_node if self.parent && self.parent.node
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

    def tree_id
      "w/hash: #{(self.hash % 1000)}"
    end

    def insert_element(node)
      if @node == nil
        @node = node
        puts "Tree at height #{self.height} inserted node #{node.display_node} "+
          "into BST" if debugging
      elsif node.data < @node.data
        if @left_child == nil
          @left_child = Tree.new
          @left_child.parent = self
          @left_child.height = self.height + 1                 if self.height
          more_indent = TREE_LIMB_INDENT - (self.height*INDENT_DECAY).floor
          more_indent = 1 if self.height > 0
          more_indent = 3 if self.height == 1
          @left_child.indent = self.indent - LEFT_NODE_INDENT*more_indent  if self.indent
        end
        @left_child.insert_element(node)
        puts "  Tree w/node #{self.node.display_node} at height #{self.height} "+
          "was traversed-left towards node #{@left_child.node.display_node}" if debugging
      elsif node.data > @node.data
        if @right_child == nil
          @right_child = Tree.new
          @right_child.parent = self
          @right_child.height = self.height + 1                  if self.height
          more_indent = TREE_LIMB_INDENT - (self.height*INDENT_DECAY).floor
          more_indent = 1 if self.height > 0
          more_indent = 3 if self.height == 1
          @right_child.indent = self.indent + RIGHT_NODE_INDENT*more_indent  if self.indent
        end
        @right_child.insert_element(node)
        puts "  Tree w/node #{self.node.display_node} at height #{self.height} "+
          "was traversed-right towards node #{@right_child.node.display_node}" if debugging
      else
        puts "Node #{node.display_node} is already in tree - ignoring" if debugging
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
    # variable names match those in book (as much as possible)
    def delete_element(tree, item)
      verbose_delete = false
      x           = nil # sub-tree object containing node to be deleted
      x_successor = nil # sub-tree object - in-order successor to x (or predecessor)
      parent      = nil # sub-tree object - parent of x, or soon its successor
      subtree     = nil # sub-tree object - subtree of x before deletion
      found       = false

      found, x, parent = bst_search(tree, item)

      if debugging && verbose_delete
        puts "Element to be deleted was found: #{found}"
        puts "Sub-tree whose node has to be deleted: #{x}"
        puts ""
        puts "Parent of sub-tree whose node has to be deleted: #{parent}"
        puts ""
      end

      return [false, tree] if ! found  # no point in going further

      if x.left_child && x.right_child
        if debugging && verbose_delete
          puts "item to be deleted #{item.data} has 2 children"
          puts "left_child: #{x.left_child.node.data}"
          puts "right_child: #{x.right_child.node.data}"
          puts ""
        end
        # item to be deleted has 2 children
        # find in-order successor (predecessor) and its parent
        # to do so as per book page 469 - start with right child of x
        # then descend left as far as possible
        x_successor = x.right_child
        parent      = x
        if debugging && verbose_delete
          puts "x_successor: #{x_successor.node.data}"
          puts "parent:      #{parent.node.data}"
          puts "---- descending left ---"
        end
        while x_successor.left_child   # descending left until last left child
          parent      = x_successor
          x_successor = x_successor.left_child
          if debugging && verbose_delete
            puts "x_successor: #{x_successor.node.data}"
            puts "parent:      #{parent.node.data}"
          end
        end

        # move content of x_successor to x, and change x to point
        # to x_successor - which will be deleted after swap
        x.node.data = x_successor.node.data
        x = x_successor

        if debugging && verbose_delete
          puts "x data updated: #{x.node.data}"
        end
      end

      # now proceed with case as if we had 0 or 1 child - book p. 466
      subtree = x.left_child
      subtree ||= x.right_child  # if left child is nil, use right child
      if debugging && verbose_delete
        puts "subtree: #{subtree}"
        puts ""
      end

      if parent == nil
        # root is being deleted, the subtree becomes root
        tree = subtree  # changing root tree to be the subtree when returned
        tree.height = 1
        tree.parent = nil
        if debugging && verbose_delete
          puts "root is being deleted subtree is new root(updated values): #{subtree}"
          tree.show_me_descendants_traverse(tree, tree.node)
        end
        tree.descendants_traverse(tree, tree.node) do |t|
          if debugging && verbose_delete
            puts "////"
            puts "inside tree: #{t.node.data}"
            puts "inside tree old height: #{t.height}"
          end
          t.height = t.parent.height+1 if t.parent
          if debugging && verbose_delete
            puts "inside tree new height: #{t.height}"
            puts "////"
          end
        end
      elsif parent.left_child == x
        parent.left_child = subtree
        if parent.left_child  # the subtree could be nil
          parent.left_child.parent = parent
          parent.left_child.height = parent.height+1
          if debugging && verbose_delete
            puts "parent left child gets the subtree(updated values): #{parent.left_child}"
            parent.show_me_descendants_traverse(parent, parent.node)
          end
          parent.descendants_traverse(parent, parent.node) do |t|
            if debugging && verbose_delete
              puts "////"
              puts "inside tree: #{t.node.data}"
              puts "inside tree old height: #{t.height}"
            end
            t.height = t.parent.height+1
            if debugging && verbose_delete
               puts "inside tree new height: #{t.height}"
               puts "////"
            end
          end
        end
      else
        parent.right_child = subtree
        if parent.right_child  # the subtree could be nil
          parent.right_child.parent = parent
          parent.right_child.height = parent.height+1
          if debugging && verbose_delete
            puts "parent right child gets the subtree(updated values): #{parent.right_child}"
            parent.show_me_descendants_traverse(parent, parent.node)
          end
          parent.descendants_traverse(parent, parent.node) do |t|
            if debugging && verbose_delete
              puts "////"
              puts "inside tree: #{t.node.data}"
              puts "inside tree old height: #{t.height}"
            end
            t.height = t.parent.height+1
            if debugging && verbose_delete
              puts "inside tree new height: #{t.height}"
              puts "////"
            end
          end
        end
      end

      x.right_child = nil
      x.left_child  = nil
      x.parent      = nil
      x.node        = nil

      return [true, tree] # tree is always the Root tree, even after old root gets deleted
    end

    def show_me_in_order_traverse(tree)
      puts ""
      puts ""
      puts ""
      puts "--"
      puts "in order traverse"
      puts "------------------"
      in_order_traverse do |tree|
        puts "inside tree: #{tree.node.data}"
        puts "--"
        puts ""
      end
    end

    def show_me_pre_order_traverse(tree)
      puts ""
      puts ""
      puts ""
      puts "--"
      puts "pre order traverse"
      puts "------------------"
      pre_order_traverse do |tree|
        puts "inside tree: #{tree.node.data}"
        puts "--"
        puts ""
      end
    end

    def show_me_post_order_traverse(tree)
      puts ""
      puts ""
      puts ""
      puts "--"
      puts "post order traverse"
      puts "------------------"
      post_order_traverse do |tree|
        puts "inside tree: #{tree.node.data}"
        puts "--"
        puts ""
      end
    end

    def in_order_traverse(&block)
      if self.node
        if self.left_child
          self.left_child.in_order_traverse(&block)
        end
        block.call(self)
        if self.right_child
          self.right_child.in_order_traverse(&block)
        end
      end
    end

    def pre_order_traverse(&block)
      if self.node
        block.call(self)
        if self.left_child
          self.left_child.pre_order_traverse(&block)
        end
        if self.right_child
          self.right_child.pre_order_traverse(&block)
        end
      end
    end

    def post_order_traverse(&block)
      if self.node
        if self.left_child
          self.left_child.post_order_traverse(&block)
        end
        if self.right_child
          self.right_child.post_order_traverse(&block)
        end
        block.call(self)
      end
    end

    def height_of_tree
      left_child_height = 0
      right_child_height = 0

      if self.left_child
        left_child_height = self.left_child.height_of_tree
      else
        left_child_height = 0  # left anchor
      end

      if self.right_child
        right_child_height = self.right_child.height_of_tree
      else
        right_child_height = 0  # right anchor
      end

      if right_child_height >= left_child_height
        return right_child_height + 1
      else
        return left_child_height + 1
      end
    end

    def show_me_right_to_left_leaf_traverse(tree)
      puts ""
      puts ""
      puts ""
      puts "--"
      puts "right to left leaf traverse"
      puts "------------------"
      right_to_left_leaf_traverse do |tree|
        puts "inside tree: #{tree.node.data}"
        puts "--"
        puts ""
      end
    end

    def right_to_left_leaf_traverse(&block)
      if self.node
        if self.right_child
          self.right_child.right_to_left_leaf_traverse(&block)
        end

        if self.right_child == nil && self.left_child == nil
          block.call(self)
        end

        if self.left_child
          self.left_child.right_to_left_leaf_traverse(&block)
        end
      end
    end

    # Ancestors traverse for 'item' element in 'tree' sub-tree
    #
    # first use search to find the element, then descend to it
    # from Root and print the ancestry nodes
    def ancestors_traverse(tree, item, &block)
      x           = nil # sub-tree object containing node to be located
      parent      = nil # sub-tree object - parent of x, or soon its successor
      found       = false

      found, x, parent = bst_search(tree, item)

      return false if ! found  # no point in going further

      locator     = tree
      parent      = nil
      found       = false

      while( !found && locator)
        if item.data < locator.node.data
          # descend left
          block.call(locator)
          parent = locator
          locator = locator.left_child
        elsif item.data > locator.node.data
          # descend right
          block.call(locator)
          parent = locator
          locator = locator.right_child
        else
          found = true
        end
      end
      return found
    end

    def show_me_ancestors_traverse(tree, item)
      if debugging || info
        puts ""
        puts ""
        puts ""
        puts "--"
        puts "Ancestors traverse starting w/item #{item.data}"
        puts "---------------------------------------"
        success =  ancestors_traverse(tree, item) do |tree|
          puts "inside tree: #{tree.node.data}"
          puts "--"
          puts ""
        end
        return success
      else
        return true
      end
    end

    # Descendants traverse for 'item' element in 'tree' sub-tree
    #
    # first use search to find the element/item, then from it
    # do a pre_order_traverse form that node and on.
    def descendants_traverse(tree, item, &block)
      x           = nil # sub-tree object containing node to be located
      parent      = nil # sub-tree object - parent of x, or soon its successor
      found       = false

      found, x, parent = bst_search(tree, item)

      return false if ! found  # no point in going further

      locator     = x     # from the located node

      if locator.left_child
        locator.left_child.pre_order_traverse(&block)
      end

      if locator.right_child
        locator.right_child.pre_order_traverse(&block)
      end

      return found
    end

    def show_me_descendants_traverse(tree, item)
      if debugging || info
        puts ""
        puts ""
        puts ""
        puts "--"
        puts "Descendants traverse starting w/item #{item.data}"
        puts "---------------------------------------"
        success =  descendants_traverse(tree, item) do |tree|
          puts "inside tree: #{tree.node.data}"
          puts "--"
          puts ""
        end
        return success
      else
        return true
      end
    end
  end
  # End of BinarySearchTree::Tree

  #
  #
  # BinarySearchTree::TreeDisplayer
  #
  class TreeDisplayer
    def self.debug; BinarySearchTree::LOG_LEVEL == BinarySearchTree::LOG_LEVEL_DEBUG; end
    def self.info;  BinarySearchTree::LOG_LEVEL == BinarySearchTree::LOG_LEVEL_INFO;  end

    def self.trees_grouped_by_level(root_tree)
      rt = root_tree
      height = rt.height_of_tree if rt
      puts ""
      levels_with_trees = {}
      height.times do |h|
        level = h+1
        levels_with_trees[level] = []
        rt.descendants_traverse(rt, rt.node) do |t|
          if t.height == level
            levels_with_trees[level] << t
          end
        end
      end
      # add root
      levels_with_trees[1] << rt
      levels_with_trees
    end

    # delcaring and setting class level attributes for
    # later access by many class level methods.
    class << self
      attr_accessor :n_size
      attr_accessor :n_padd
      attr_accessor :n_dash
      attr_accessor :lp_char
      attr_accessor :rp_char
      attr_accessor :mp_char
    end

    self.n_size  =  BinarySearchTree::Tree::NODE_DATA_SIZE
    self.n_padd  =  BinarySearchTree::Tree::NODE_DATA_PADDING
    self.n_dash  =  BinarySearchTree::Tree::NUM_OF_DASHES
    self.lp_char = ' ' #'L' # ' '
    self.rp_char = ' ' #'R' # ' '
    self.mp_char = ' ' #'M' # ' '

    def self.adjust_indentations_to_avoid_collision(rt, levels_and_trees)
      levels_and_trees.each_pair do |level, trees|
        trees.each_with_index do |t, i|

          if i > 0  # start compare with second element
            if trees[i].indent == trees[i-1].indent
              if debug || info
                puts ""
                puts "*"*30
                puts "Collision Detected - Node #{t.node.data} & Node #{trees[i-1].node.data}"
                puts ""
                puts "Level #{level}: #{trees.map {|tt| tt.node.data}}"
                puts "Indent: #{t.indent}"
                puts "*"*30
                puts ""
                puts "-"*30
              end
              # do adjustment on all ancestors
              rt.ancestors_traverse(rt, t.node) do |tree|
                tree.indent += 4
                #rt.descendants_traverse(rt, t.parent.node) {|x| x.indent += 4 }
              end
              #t.indent += 4   # do adjustment on current node
              rt.descendants_traverse(rt, t.parent.node) {|x| x.indent += 4 }
              if debug || info
                puts "Node #{t.node.data} and its ancestors and all their"
                puts "right hand descendants indentation were adjusted right by 4"
                puts "-"*30
                sleep 10
              end
            end
          end
        end
      end
    end

    def self.display_tree_2D(*root)
      rt = root[0]
      levels_with_trees = trees_grouped_by_level(rt)
      adjust_indentations_to_avoid_collision(rt, levels_with_trees)

      boxes_array         = []
      slashes_array       = []
      slashes_above_array = []

      # we want to align the array index with the level,
      # so ignore 1st element of array
      boxes_array[0]         = []
      slashes_array[0]       = []
      slashes_above_array[0] = []

      levels_with_trees.each_pair do |level, trees|
        log_levels_and_trees(level, trees)

        accumulator   = ''
        boxes         = []
        slashes       = []
        slashes_above = []
        trees.each_with_index do |t, i|
          accumulator = left_side_spacing(level, t, i, accumulator, boxes, slashes, slashes_above)
          add_slashes_below_node(t, slashes)
          add_slashes_above_node(level, t, slashes_above)
          accumulator = add_data_box(t, accumulator, boxes)
          accumulator = middle_spacing(level, t, i, accumulator, boxes, slashes, slashes_above, trees)
          accumulator = right_side_spacing(level, t, i, accumulator, boxes, trees)
        end
        boxes_array[level] = boxes
        slashes_array[level] = slashes
        slashes_above_array[level] = slashes_above
      end
      #display_original_array(rt)
      display_complete_tree(boxes_array, slashes_array, slashes_above_array)
    end

    def self.add_slashes_below_node(t, slashes)
      if t.right_child && t.left_child                   # t has both children
        slashes <<   '/  \\'
      elsif  t.left_child                                # t has a left child
        slashes <<   '/ ' + ' '*n_padd + ' '*n_padd
      elsif  t.right_child                               # t has a right  child
        slashes << ' '*n_padd + ' '*n_padd +  ' \\'
      elsif  t.right_child == nil && t.left_child == nil # t has no children
        slashes << ' '*n_padd +  '~~' + ' '*n_padd
      end
    end

    def self.add_slashes_above_node(level, t, slashes_above)
      if level > 2  # don't do it for root node
        if  t.parent && t.parent.right_child == t          # t is the right child
          slashes_above <<  '\\ ' + ' '*n_padd + ' '*n_padd
        elsif  t.parent && t.parent.left_child == t        # t is the left child
          slashes_above <<  ' '*n_padd + ' '*n_padd + ' /'
        end
      elsif level == 2  # special treatment for second level to pretty display
        if  t.parent && t.parent.right_child == t          # t is the right child
          slashes_above <<  '--------\\ ' + ' '*n_padd + ' '*n_padd
        elsif  t.parent && t.parent.left_child == t        # t is the left child
          slashes_above <<  ' '*n_padd + ' '*n_padd + ' /--------'
        end
      end
    end

    def self.left_side_spacing(level, t, i, accumulator, boxes, slashes, slashes_above)
      if i == 0  # do it only for left most (i.e first) element of each level
        left_side_padding = t.indent - (n_size/2).ceil - n_padd
        left_side_padding = 0 if left_side_padding < 0
        l_box = lp_char*left_side_padding
        accumulator << l_box
        slashes << l_box
        if level == 2 && t.parent.left_child == nil # our left sibling is nil
          # special treatment for second level to pretty it up
          l_padding = left_side_padding - n_dash
          l_padding = 0 if l_padding < 0
          l_box_above = lp_char*l_padding
          slashes_above << l_box_above
        else
          slashes_above << l_box   if level > 1
        end
        boxes << l_box
      end
      return accumulator
    end

    def self.add_data_box(t, accumulator, boxes)
      data_box = ' '*n_padd + t.node.data.to_s + ' '*n_padd
      data_box = ' ' + data_box if t.node.data < 10  # to deal with 1 digit numbers
      accumulator << data_box
      boxes << data_box
      return accumulator
    end

    def self.middle_spacing(level, t, i, accumulator, boxes, slashes, slashes_above, trees)
      if trees.size-1 > 0 && i < trees.size-1
        middle_padding = trees[i+1].indent - t.indent - n_padd*4
        if level == 2  # special treatment for second level to pretty display
          # to allow for /-------- -------\
          middle_padding_4_slashes_above = middle_padding - n_dash*2
          middle_padding_4_slashes_above = 0 if middle_padding_4_slashes_above < 0
        end
        middle_padding = 0 if middle_padding < 0
        m_box = mp_char*middle_padding
        if level == 2  # special treatment for second level to pretty display
          m_box_above = mp_char*middle_padding_4_slashes_above
        end
        accumulator << m_box
        boxes << m_box
        slashes << m_box
        if level == 2  # special treatment for second level to pretty display
          slashes_above << m_box_above
        else
          slashes_above << m_box   if level > 1
        end
      end
      return accumulator
    end

    def self.right_side_spacing(level, t, i, accumulator, boxes, trees)
      if i == trees.size - 1
        right_side_padding = (BinarySearchTree::ROOT_NODE_INDENT*2).floor -
          accumulator.size - (n_size/2).ceil
        right_side_padding = 0 if right_side_padding < 0
        r_box = rp_char*right_side_padding
        accumulator << r_box
        boxes << r_box
      end
      return accumulator
    end

    def self.display_complete_tree(boxes_array, slashes_array, slashes_above_array)
      boxes_array.each_with_index do |a, i|
        puts slashes_above_array[i].join('')
        puts a.join('')
        puts slashes_array[i].join('')
      end
    end

    def self.display_original_array(rt)
      if debug || info
        puts "The array we just inserted:"
        tmp_array = []
        rt.pre_order_traverse do |t|
          tmp_array << t.node.data
        end
        puts "#{tmp_array}"
      end
    end

    def self.log_levels_and_trees(level, trees)
      if debug
        puts "Level #{level}: #{trees.map {|t| t.node.data}}"

        trees.each_with_index do |t, i|
           puts "tree at index[#{i}] with node #{t.node.data} has indent: #{t.indent}"
        end
      end
    end
  end
  # my beloved measuring stick
  # 1234567890123456789012345678901234567890123456789012345678901234567890
  #
  # End of BinarySearchTree::TreeDisplayer
end
