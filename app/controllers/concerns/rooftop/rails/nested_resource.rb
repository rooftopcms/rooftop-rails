module Rooftop
  module Rails
    # A controller mixin which can load a resource from a nested path. Useful mostly for pages.
    # The mixin defines some dynamic instance methods on the controller, and a class method to define the name of the model you want to load.
    module NestedResource
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        attr_reader :resource_name, :resource_class
        # A class method defined on the controller which gives you an easy way to find a resource from a deeply-nested path, and optionally check that the path provided is correct.
        # By adding a call to `nested_rooftop_resource` in your controller class, the following happens:
        # - The resource model you identify has Rooftop::Rails::NestedModel mixed into it
        # - Methods for finding a model object and validating that the path is correct are added
        # @example
        #     class PagesController
        #       include Rooftop::Rails::NestedResource
        #       nested_rooftop_resource :page
        #       before_action :find_and_validate_page, except: :index
        #     end
        #
        # Note that the methods on the controller are dynamically named according to the resource name - i.e. find_and_validate_page in this case.
        # You need to set up your routes so that a single param called `nested_path` is passed to this controller for any methods you're calling `find_and_validate_page` on, for example:
        # match "/*nested_path", via: [:get], to: "pages#show"
        # This is a greedy route so you probably want it at the bottom.
        def nested_rooftop_resource(resource)
          @resource_name = resource
          @resource_class = resource.to_s.classify.constantize
          @resource_class.send(:include, Rooftop::Rails::NestedModel)

          # Set up the dynamically-named find_[resource name]
          define_method "find_#{@resource_name}" do
            respond_to do |format|
              format.html do
                resource = self.class.resource_class.send(:find_by_nested_path, params[:nested_path])
                instance_variable_set("@#{self.class.resource_name}",resource)
              end
              format.all do
                raise ActionController::RoutingError, "Not found: #{request.original_fullpath}"
              end
            end

          end
          # Set up the dynamically-named validate_[resource name]
          define_method "validate_#{@resource_name}" do
            resource = instance_variable_get("@#{self.class.resource_name}")
            if resource.nested_path != params[:nested_path]
              raise Rooftop::Rails::AncestorMismatch, "The #{self.class.resource_name} you requested has a different path"
            end
          end
          # Set up the dynamically-named find_and_validate_[resource name]
          # (this is a utility method to call the two above)
          define_method "find_and_validate_#{@resource_name}" do
            send(:"find_#{self.class.resource_name}")
            send(:"validate_#{self.class.resource_name}")
          end
        end
      end



    end
  end
end