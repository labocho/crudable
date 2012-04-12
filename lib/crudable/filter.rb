module Crudable
  module Filter
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end

    module ClassMethods
      # Example:
      #   class TweetsController
      #     before_filter :find_and_assign_tweet, except: [:index, :new, :create]
      #     crudable_filter
      #     # model : Tweet
      #     # object : "tweet"
      #     # parent : nil
      #   end
      #
      # Options:
      #   model     : Model class. (default: guess by controller class name)
      #   object    : Instance variable name (minus @) that contain model object. (default: guess by controller class name)
      #   parent    : Instance variable name (minus @) that contain model's parent object. (default: nil)
      #               If you want to switch by action, pass hash like {creatable: "foo", readable: "bar"}.
      #               Or pass proc receives context and return parent object for more complex behaivier.
      #   creatable : Action names that filter by accept_creatable. (default: [:new, :create])
      #   readable  : Action names that filter by accept_readable. (default: [:index, :show])
      #   updatable : Action names that filter by accept_updatable. (default: [:edit, :update])
      #   deletable : Action names that filter by accept_deletable. (default: [:destroy])
      def crudable_filter(options = {})
        @model_class = options[:model] || self.to_s.gsub(/Controller$/, "").singularize.constantize
        @object_name = options[:object] || self.to_s.gsub(/^.*::/, "").gsub(/Controller$/, "").singularize.underscore
        @parent_name = case options[:parent]
        when String, Symbol, Proc
          {creatable: options[:parent], readable: options[:parent]}
        else
          options[:parent] || {}
        end

        (class << self; self; end).class_eval do
          define_method(:model_class) { @model_class }
          define_method(:object_name) { @object_name }
          define_method(:parent_name) { @parent_name }
        end

        action_types = {
          creatable: [:new, :create],
          readable: [:index, :show],
          updatable: [:edit, :update],
          deletable: :destroy
        }
        action_types.update(options)

        action_types.each_pair do |auth_type, actions|
          next if actions.blank?
          case auth_type
          when :creatable, :readable, :updatable, :deletable
            before_filter "accept_#{auth_type}", only: actions
          end
        end
      end
    end

    module InstanceMethods
      # Call when authorization failed.
      # Render simple text and return false to halt filter chain immediately.
      # You can override this.
      def reject_request
        render text: "403 Forbidden", status: 403
        false
      end

      # Call when authorization failed. You can override this.
      # Do nothing. You can override this.
      def accept_request
      end

      # User-like object pass to xxx-able? method as first argument.
      def current_user_object
        current_user
      end

      def accept_creatable
        args = [current_user_object]
        if parent = get_parent_record(:creatable)
          args << parent
        end

        get_model.creatable?(*args) ? accept_request : reject_request
      end

      def accept_readable
        if record = get_record
          record.readable?(current_user_object) ? accept_request : reject_request
        else
          args = [current_user_object]
          if parent = get_parent_record(:readable)
            args << parent
          end

          get_model.readable?(*args) ? accept_request : reject_request
        end
      end

      def accept_updatable
        get_record.updatable?(current_user_object) ? accept_request : reject_request
      end

      def accept_deletable
        get_record.deletable?(current_user_object) ? accept_request : reject_request
      end

      private
      def get_model
        self.class.model_class
      end

      def get_record
        instance_variable_get("@#{self.class.object_name}")
      end

      def get_parent_record(context)
        case self.class.parent_name[context]
        when String, Symbol
          instance_variable_get("@#{self.class.parent_name[context]}")
        when Proc
          instance_eval &self.class.parent_name[context]
        end
      end
    end
  end
end
