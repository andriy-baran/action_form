# frozen_string_literal: true

module EasyForm
  # Provides methods for rendering form elements and forms
  module Rendering
    def render_elements(elements = elements_instances)
      elements.select(&:render?).each do |element|
        if element.is_a?(SubformCollection)
          render_many_subforms(element)
        elsif element.is_a?(Subform)
          render_subform(element)
        elsif element.input_type == :hidden
          input(**element.input_html_attributes)
        elsif element.errors_messages.any?
          render_element_with_errors(element)
        elsif element.tags[:template]
          # NOOP
        else
          render_element(element)
        end
      end
    end

    def render_element(element)
      render_label(element)
      render_input(element)
    end

    def render_element_with_errors(element)
      render_label(element)
      render_input_with_errors(element)
    end

    def render_label(element)
      return if hide_label?(element)

      label(**element.label_html_attributes) { element.label_text }
    end

    def render_input_with_errors(element)
      render_input(element)
      render_errors(element)
    end

    def render_input(element, **html_attributes)
      render Input.new(element, **html_attributes)
    end

    def render_errors(element)
      div(class: "error-messages") { element.errors_messages.join(", ") }
    end

    def render_form(**html_attributes, &block)
      form(**@html_options, **html_attributes, &block)
    end

    def render_subform(subform)
      render_elements(subform.elements_instances)
    end

    def render_many_subforms(subforms)
      subforms.each(&method(:render_subform))
    end

    def render_validated_form(&block)
      render_form(&block)
    end

    def render_submit(**html_attributes)
      input(name: "commit", type: "submit", value: "Submit", **html_attributes)
    end

    private

    def hide_label?(element)
      return true unless element.class.label_options.first[:display]

      element.input_type == :hidden ||
        (%i[checkbox radio].include?(element.input_type) && element.class.select_options.any?)
    end
  end
end
