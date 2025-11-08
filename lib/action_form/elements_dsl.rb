# frozen_string_literal: true

module ActionForm
  # Provides a DSL for defining form elements with input and output configurations.
  # This module allows form classes to define elements using a simple block syntax.
  # Elements can be configured with input types, output formats, labels and other options.
  #
  # @example
  #   class UserForm < ActionForm::Base
  #     element :name do
  #       input type: :text
  #       label text: "Full Name"
  #     end
  #   end
  module ElementsDSL
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods # rubocop:disable Style/Documentation
      def elements
        @elements ||= {}
      end

      # TODO: add support for outputless elements
      def element(name, &block)
        @params_definition = nil
        elements[name] = Class.new(ActionForm::Element)
        elements[name].class_eval(&block)
        define_singleton_method(:"#{name}_element") do |klass = nil, &block|
          update_element_definition(name, klass, &block)
        end
      end

      def many(name, default: nil, &block)
        @params_definition = nil
        subform_definition = Class.new(ActionForm::SubformsCollection)
        subform_definition.host_class = self
        subform_definition.class_eval(&block) if block
        elements[name] = subform_definition
        elements[name].default = default if default
        define_singleton_method(:"#{name}_subforms") do |klass = nil, default: nil, &block|
          update_element_definition(name, klass, default: default, &block)
        end
      end

      def subform(name, default: nil, &block)
        @params_definition = nil
        elements[name] = Class.new(subform_class)
        elements[name].class_eval(&block)
        elements[name].default = default if default
        define_singleton_method(:"#{name}_subform") do |klass = nil, default: nil, &block|
          update_element_definition(name, klass, default: default, &block)
        end
      end

      private

      def update_element_definition(name, klass = nil, default: nil, &block)
        elements[name] = klass if klass
        elements[name] = Class.new(elements[name], &block) if block
        elements[name].default = default if default
      end
    end
  end
end
