# frozen_string_literal: true

require "phlex"

module EasyForm
  module Inputs
    class Label < Phlex::HTML
      def initialize(text: nil, for: nil, label_attrs: {})
        @text = text
        @for = binding.local_variable_get(:for)
        @label_attrs = label_attrs || {}
      end

      def view_template(&content)
        attrs = {}
        attrs[:for] = @for if @for

        if block_given?
          label(**attrs.merge(@label_attrs)) { self << content.call }
        else
          label(**attrs.merge(@label_attrs)) { @text }
        end
      end
    end
  end
end
