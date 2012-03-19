require "./shipping_options.rb"

class MediaMail < ShippingOption
  def self.can_ship?(weight, international)
    !international
  end
end
