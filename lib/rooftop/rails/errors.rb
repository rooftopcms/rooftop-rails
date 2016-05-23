module Rooftop
  module Rails
    class AncestorMismatch < StandardError; end
    class UnknownObjectForExpiry < NoMethodError; end
  end
end