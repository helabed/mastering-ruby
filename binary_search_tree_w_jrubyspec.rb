require './binary_search_tree'
require 'securerandom'
require 'set'
require 'active_support/all'
require 'pry'


RSpec.describe 'BinarySearchTree (BST) - display in JRuby/Java Swing' do
  it 'should search for an element stored in BST' do
    total_num_of_items = 15
    randomness_range = 100
    edge = [
      Array.new(total_num_of_items) { SecureRandom.random_number(randomness_range) },
    ]

    aggregate_failures "aggregate array for #{edge.size} arrays" do
      edge.each do |rand_array|
        rand_array.shuffle!
        rand_array = [3,1,5,0,2]
        puts ""
        bst = BinarySearchTree.new
        L = Logger
        L.log rand_array, 'the array'
        bst.insert_into(rand_array)
        bst.display_tree

        SwingTreeDisplayer.display_tree_w_swing(bst)
      end
    end
  end
end


#
# a single Connection line to keep track of
# which button is connected to the other
#
class Connection
  #javax.swing.JButton source
  attr_accessor :source
  attr_accessor :destination

  def initialize(src, dest)
    @source      = src
    @destination = dest
  end
end
# End of Connection


#
# a Connection Panel for drawing Connection Lines
# to the connected buttons
#
class ConnectionsPanel < javax.swing.JPanel
  attr_accessor :connections
  attr_accessor :v_panel_x
  attr_accessor :v_panel_y
  attr_accessor :v_panel_width
  attr_accessor :v_panel_height

  def horizontalCenter(bounds)
    return bounds.getX() + bounds.getWidth() / 2
  end

  def verticalCenter(bounds)
    return bounds.getY() + bounds.getHeight() / 2
  end

  @Override
  def paintComponent(g)
    super(g)
    g2d = g.create()
    g2d.setColor(java.awt.Color::RED)

    @connections.each do |c|
      # puts "I am connection: #{c.inspect}"
      # puts "g.inspect #{g.inspect}"
      source = c.source
      dest = c.destination

      if source && dest
        puts "source x: #{source.getX}, y: #{source.getY}"
        puts "dest x: #{dest.getX}, y: #{dest.getY}"
        if (source.getX() == dest.getX())
          # Same column...
          g2d.drawLine(source.getX() + source.getWidth() / 2, source.getY(),
            dest.getX() + source.getWidth() / 2, dest.getY());
        elsif (source.getY() == dest.getY())
          # Same row...
          offset = 200
          g2d.drawLine(source.getX() + v_panel_x + offset,
                       source.getY() + v_panel_y + source.getHeight() / 2 + offset,
                       dest.getX() + v_panel_x + offset + 100,
                       dest.getY() + v_panel_y + dest.getHeight() / 2 + offset + 100);
        else
          # diagonal from each other
          path = new java.awt.geom.Path2D.Double();
          path.moveTo(horizontalCenter(source), verticalCenter(source));
          path.curveTo(horizontalCenter(source), verticalCenter(dest),
                          horizontalCenter(source), verticalCenter(dest),
                          horizontalCenter(dest), verticalCenter(dest));
          g2d.draw(path);
        end
      end
    end
    g2d.dispose();
  end
end
# End of ConnectionsPanel


#
# Java Swing BST displayer in JRuby
#
class SwingTreeDisplayer
  def self.display_tree_w_swing(bst)
    connections = []
    buttons = {}
    levels_with_trees = BinarySearchTree::TreeDisplayer.trees_grouped_by_level(bst.root_tree)
    # Java swing library below in preparation for displaying trees & nodes
    # in Swing
    frame = javax.swing.JFrame.new("JRuby is Awesome! - for displaying a BST and More")
    frame.set_size 600, 600
    vertical_grid = java.awt.GridLayout.new(bst.height_of_tree, 1)
    v_panel = javax.swing.JPanel.new
    v_panel.set_layout(vertical_grid)
    v_panel_border =
      javax.swing.BorderFactory.createLineBorder(java.awt.Color::BLUE,1)
    v_panel.set_border(v_panel_border)
    levels_with_trees.each_pair do |level, trees|
      panel = javax.swing.JPanel.new
      panel.set_layout(java.awt.FlowLayout.new)
      panel_border =
        javax.swing.BorderFactory.createLineBorder(java.awt.Color::GREEN,1)
      panel.set_border(panel_border)
      trees.each_with_index do |t, i|
        button = javax.swing.JButton.new(t.node.data.to_s)
        buttons[t.node.data] = button
        if t.parent
          connections << Connection.new(buttons[t.parent.node.data], button)
        else
          connections << Connection.new(nil, button) # when t is root
        end
        button.add_action_listener { button.text = "L#{level}t#{i+1}" }
        panel.add button
      end
      v_panel.add(panel)
    end
    c_panel = ConnectionsPanel.new
    c_panel.connections = connections
    connection_panel_border =
      javax.swing.BorderFactory.createLineBorder(java.awt.Color::ORANGE,1)
    c_panel.set_border(connection_panel_border)
    c_panel.add(v_panel)
    frame.add(c_panel)
    frame.show
    c_panel.v_panel_x = v_panel.bounds.x
    c_panel.v_panel_y = v_panel.bounds.y
    c_panel.v_panel_width  = v_panel.bounds.width
    c_panel.v_panel_height = v_panel.bounds.height
    puts "v_panel x: #{c_panel.v_panel_x}, y: #{c_panel.v_panel_y}"
    #binding.pry
  end
end
# End of SwingTreeDisplayer
