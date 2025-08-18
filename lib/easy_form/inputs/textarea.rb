# frozen_string_literal: true

require "phlex"

module EasyForm
  module Inputs
    class Textarea < Phlex::HTML
      def initialize(name:, id:, cols:, rows:, textarea_attrs: {})
        @name = name
        @id = id
        @cols = cols
        @rows = rows
        @textarea_attrs = textarea_attrs || {}
      end

      def view_template
        attrs = { name: @name, id: @id, cols: @cols, rows: @rows }
        textarea(**attrs.merge(@textarea_attrs))
      end
    end
  end
end
