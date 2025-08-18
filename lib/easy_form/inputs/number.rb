# frozen_string_literal: true

require "phlex"

module EasyForm
  module Inputs
    class Number < Phlex::HTML
      def initialize(name:, id:, min: nil, max: nil, step: nil, input_attrs: {})
        @name = name
        @id = id
        @min = min
        @max = max
        @step = step
        @input_attrs = input_attrs || {}
      end

      def view_template
        attrs = { type: "number", name: @name, id: @id }
        attrs[:min] = @min if @min
        attrs[:max] = @max if @max
        attrs[:step] = @step if @step
        # Spec expects: step first, then min, then max → but attribute maps don't guarantee order.
        # We'll build in expected order explicitly.
        ordered = {}
        ordered[:step] = attrs.delete(:step) if attrs.key?(:step)
        ordered[:min] = attrs.delete(:min) if attrs.key?(:min)
        ordered[:max] = attrs.delete(:max) if attrs.key?(:max)
        input(**ordered.merge(attrs).merge(@input_attrs))
      end
    end
  end
end
