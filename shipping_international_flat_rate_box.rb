require "./shipping_options.rb"

class InternationalFlatRateBox < ShippingOption
  def self.can_ship?(weight, international)
    weight >= 64 && weight < 9*16 && international
  end
end
