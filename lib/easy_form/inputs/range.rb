# frozen_string_literal: true

require "phlex"

module EasyForm
  module Inputs
    class Range < Phlex::HTML
      def initialize(name:, id:, min: nil, max: nil, input_attrs: {})
        @name = name
        @id = id
        @min = min
        @max = max
        @input_attrs = input_attrs || {}
      end

      def view_template
        attrs = { type: "range", name: @name, id: @id }
        attrs[:min] = @min if @min
        attrs[:max] = @max if @max
        # Expected order: min, max, type, name, id
        ordered = {}
        ordered[:min] = attrs.delete(:min) if attrs.key?(:min)
        ordered[:max] = attrs.delete(:max) if attrs.key?(:max)
        input(**ordered.merge(attrs).merge(@input_attrs))
      end
    end
  end
end
