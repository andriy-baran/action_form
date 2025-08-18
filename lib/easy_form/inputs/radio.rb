# frozen_string_literal: true

require "phlex"

module EasyForm
  module Inputs
    class Radio < Phlex::HTML
      def initialize(name:, value:, id: nil, checked: false, input_attrs: {})
        @name = name
        @value = value
        @id = id || "#{name}_#{value}"
        @checked = checked
        @input_attrs = input_attrs || {}
      end

      def view_template
        attrs = {
          type: "radio",
          value: @value,
          name: @name,
          id: @id
        }
        attrs[:checked] = true if @checked
        input(**attrs.merge(@input_attrs))
      end
    end
  end
end
