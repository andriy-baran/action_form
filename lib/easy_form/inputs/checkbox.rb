# frozen_string_literal: true

require "phlex"

module EasyForm
  module Inputs
    class Checkbox < Phlex::HTML
      def initialize(
        name:,
        id: nil,
        value: "1",
        unchecked_value: "0",
        checked: false,
        autocomplete: "off",
        input_attrs: {}
      )
        @name = name
        @id = id || name
        @value = value
        @unchecked_value = unchecked_value
        @checked = checked
        @autocomplete = autocomplete
        @input_attrs = input_attrs || {}
      end

      def view_template
        # Hidden field for the unchecked value to mimic Rails behavior
        # Attribute order matches spec expectation: name, type, value, autocomplete
        input name: @name, type: "hidden", value: @unchecked_value, autocomplete: @autocomplete

        # Attribute order matches spec expectation: type, value, name, id
        checkbox_attributes = {
          type: "checkbox",
          value: @value,
          name: @name,
          id: @id
        }
        checkbox_attributes[:checked] = true if @checked

        input(**checkbox_attributes.merge(@input_attrs))
      end
    end
  end
end
