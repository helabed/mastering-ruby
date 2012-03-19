class ShippingOption   # Base class
  @children = []  
  def self.inherited(child)
    @children << child
  end
  def self.shipping_options(weight, international)
    @children.select {|child| child.can_ship?(weight, international)}
  end
end
