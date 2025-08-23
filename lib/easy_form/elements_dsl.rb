# frozen_string_literal: true

module EasyForm
  # Provides a DSL for defining form elements with input and output configurations.
  # This module allows form classes to define elements using a simple block syntax.
  # Elements can be configured with input types, output formats, labels and other options.
  #
  # @example
  #   class UserForm < EasyForm::Base
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
        elements[name] = Class.new(EasyForm::Element)
        elements[name].class_eval(&block)
      end

      def has_many(name, &block) # rubocop:disable Naming/PredicatePrefix
        elements[name] = [Class.new(subform_class)]
        elements[name].last.class_eval(&block)
      end

      def has_one(name, &block) # rubocop:disable Naming/PredicatePrefix
        elements[name] = Class.new(subform_class)
        elements[name].class_eval(&block)
      end
    end
  end
end
