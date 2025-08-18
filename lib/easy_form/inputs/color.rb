# frozen_string_literal: true

require "phlex"

module EasyForm
  module Inputs
    class Color < Phlex::HTML
      def initialize(name:, id:, value: "#000000", input_attrs: {})
        @name = name
        @id = id
        @value = value
        @input_attrs = input_attrs || {}
      end

      def view_template
        attrs = { value: @value, type: "color", name: @name, id: @id }
        input(**attrs.merge(@input_attrs))
      end
    end
  end
end
