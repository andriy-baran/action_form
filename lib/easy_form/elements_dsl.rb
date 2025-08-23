# frozen_string_literal: true

module EasyForm
  module ElementsDSL
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def elements
        @elements ||= {}
      end

      # TODO: add support for outputless elements
      def element(name, &block)
        elements[name] = Class.new(EasyForm::Element)
        elements[name].class_eval(&block)
      end
    end
  end
end
