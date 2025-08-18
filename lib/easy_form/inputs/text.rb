# frozen_string_literal: true

require "phlex"

module EasyForm
  module Inputs
    class Text < Phlex::HTML
      def initialize(name:, id:, input_attrs: {})
        @name = name
        @id = id
        @input_attrs = input_attrs || {}
      end

      def view_template
        input(**{ type: "text", name: @name, id: @id }.merge(@input_attrs))
      end
    end
  end
end
