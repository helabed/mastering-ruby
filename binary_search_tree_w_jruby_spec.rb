#in coderpad.io/sandbox, copy file binary_search_tree.rb
#to the bottom of this file and comment out this
#require line below.
require './binary_search_tree'
#comment out this line for below standlone RSpec (i.e when NOT in coderpad)
#require 'rspec/autorun'
##The above statements are useful when running in
##coderpad.io/sandbox - otherwise comment out
require 'securerandom'
require 'set'
require 'active_support/all'
require 'pry'
#require 'byebug'


RSpec.describe 'BinarySearchTree (BST) - display in JRuby/Java Swing' do
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

        rand_array = [3,1,5,0,2]
        puts ""
        puts ""
        bst = BinarySearchTree.new
        L = Logger

        L.log rand_array, 'the array'
        bst.insert_into(rand_array)

        # accumulator = []
        # outcome = bst.do_ancestors_traverse(item_to_traverse_from) do |t|
        #   accumulator << t.node.data
        # end
        # expect(outcome).to be true
        #
        # accumulator = []
        # outcome = bst.do_descendants_traverse(item_to_traverse_from) do |t|
        #   accumulator << t.node.data
        # end
        # expect(outcome).to be true

        bst.display_tree

        class Connection
          #javax.swing.JButton source
          attr_accessor :source
          attr_accessor :destination

          def initialize(src, dest)
            @source      = src
            @destination = dest
          end
        end

        class ConnectionsPane < javax.swing.JPanel
          attr_accessor :connections
          attr_accessor :vertical_panel_x
          attr_accessor :vertical_panel_y
          attr_accessor :vertical_panel_width
          attr_accessor :vertical_panel_height

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
                  g2d.drawLine(source.getX() + vertical_panel_x + offset,
                               source.getY() + vertical_panel_y + source.getHeight() / 2 + offset,
                               dest.getX() + vertical_panel_x + offset + 100,
                               dest.getY() + vertical_panel_y + dest.getHeight() / 2 + offset + 100);
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

        connections = []
        buttons = {}
        levels_with_trees = BinarySearchTree::TreeDisplayer.trees_grouped_by_level(bst.root_tree)
        # Java swing library below in preparation for displaying trees & nodes
        # in Swing
        frame = javax.swing.JFrame.new("JRuby is Awesome!")
        frame.set_size 600, 600
        vertical_grid = java.awt.GridLayout.new(bst.height_of_tree, 1)
        vertical_panel = javax.swing.JPanel.new
        vertical_panel.set_layout(vertical_grid)
        vertical_panel_border =
          javax.swing.BorderFactory.createLineBorder(java.awt.Color::BLUE,1)
        vertical_panel.set_border(vertical_panel_border)
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
          vertical_panel.add(panel)
        end
        connection_pane = ConnectionsPane.new
        connection_pane.connections = connections
        connection_pane_border =
          javax.swing.BorderFactory.createLineBorder(java.awt.Color::ORANGE,1)
        connection_pane.set_border(connection_pane_border)
        connection_pane.add(vertical_panel)
        frame.add(connection_pane)
        frame.show
        connection_pane.vertical_panel_x = vertical_panel.bounds.x
        connection_pane.vertical_panel_y = vertical_panel.bounds.y
        connection_pane.vertical_panel_width  = vertical_panel.bounds.width
        connection_pane.vertical_panel_height = vertical_panel.bounds.height
        puts "vertical_panel x: #{connection_pane.vertical_panel_x}, y: #{connection_pane.vertical_panel_y}"
        #binding.pry
      end
    end
  end
end
