# frozen_string_literal: true

module EasyForm
  # Provides methods for rendering form elements and forms
  module Rendering
    def render_elements(elements = elements_instances)
      elements.select(&:render?).each do |element|
        if element.is_a?(SubformsCollection)
          render_many_subforms(element)
        elsif element.is_a?(Subform)
          render_subform(element)
        elsif element.input_type == :hidden
          input(**element.input_html_attributes)
        else
          render_element(element)
        end
      end
    end

    def render_element(element)
      render_label(element)
      render_input(element)
      render_inline_errors(element) if element.tags[:errors]
    end

    def render_label(element)
      return if hide_label?(element)

      label(**element.label_html_attributes) { element.label_text }
    end

    def render_input(element, **html_attributes)
      render Input.new(element, **html_attributes)
    end

    def render_inline_errors(element)
      div(class: "error-messages") { element.errors_messages.join(", ") }
    end

    def render_form(**html_attributes, &block)
      form(**@html_options, **html_attributes, &block)
    end

    def render_subform(subform)
      render_elements(subform.elements_instances)
    end

    def render_many_subforms(subforms)
      subforms.each do |subform|
        if subform.tags[:template]
          render_subform_template(subform)
        else
          render_subform(subform)
        end
      end
    end

    def render_subform_template(subform)
      template(id: subform.template_html_id) do
        render_subform(subform)
      end
    end

    def render_submit(**html_attributes)
      input(name: "commit", type: "submit", value: "Submit", **html_attributes)
    end

    def render_remove_subform_button(subform, **html_attributes, &block)
      a(**html_attributes, onclick: safe("easyFormRemoveSubform(event)"), &block)
      script(type: "text/javascript") do
        raw safe(<<~JS)
          function easyFormRemoveSubform(event) {
            event.preventDefault()
            event.target.parentElement.remove()
          }
        JS
      end
    end

    def render_new_subform_button(subforms, **html_attributes, &block)
      a(**html_attributes, onclick: safe("easyFormAddSubform(event)"), &block)
    end

    private

    def hide_label?(element)
      return true unless element.class.label_options.first[:display]

      element.input_type == :hidden ||
        (%i[checkbox radio].include?(element.input_type) && element.class.select_options.any?)
    end
  end
end
