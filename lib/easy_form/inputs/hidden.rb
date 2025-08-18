# frozen_string_literal: true

require "phlex"

module EasyForm
  module Inputs
    class Hidden < Phlex::HTML
      def initialize(name:, id:, value:, autocomplete: "off", input_attrs: {})
        @name = name
        @id = id
        @value = value
        @autocomplete = autocomplete
        @input_attrs = input_attrs || {}
      end

      def view_template
        # Expected order: value, autocomplete, type, name, id
        attrs = {
          value: @value,
          autocomplete: @autocomplete,
          type: "hidden",
          name: @name,
          id: @id
        }
        input(**attrs.merge(@input_attrs))
      end
    end
  end
end
