module RooftopRails
  module Menu
    def self.included(base)
      base.include RooftopRubyClient::Base
      base.extend ClassMethods
      base.send(:collection_path, "menus")
    end

    module ClassMethods
    end
  end
end