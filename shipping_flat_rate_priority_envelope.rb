require "./shipping_options.rb"

class FlatRatePriorityEnvelope < ShippingOption
  def self.can_ship?(weight, international)
    weight < 64 && !international
  end
end
