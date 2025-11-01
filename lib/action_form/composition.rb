# frozen_string_literal: true

module ActionForm
  # Provides host–guest association helpers for ActionForm components.
  # When included, it exposes `host_object` and `host_association_name` accessors
  # and delegates `host_*` method calls to the associated host via `method_missing`.
  module Composition
    def self.included(base)
      base.attr_accessor :owner
      base.include(InstanceMethods)
      base.extend(ClassMethods)
    end

    module ClassMethods # rubocop:disable Style/Documentation
      def part_of(owner_name)
        @owner_name = owner_name
        alias_method owner_name, :owner
      end
    end

    module InstanceMethods # rubocop:disable Style/Documentation
      def method_missing(name, *attrs, **kwargs, &block)
        if (handler = owners_chain.lazy.detect { |o| o.public_methods.include?(name) })
          handler.public_send(name, *attrs, **kwargs, &block)
        else
          super
        end
      end

      def respond_to_missing?(method_name, _include_private = false)
        public_methods.detect { |m| m == :owner } || super
      end

      def owners_chain
        obj = self
        Enumerator.new do |y|
          y << obj = obj.owner while obj.public_methods.include?(:owner)
        end
      end
    end
  end
end
