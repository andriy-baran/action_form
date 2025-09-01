# frozen_string_literal: true

module EasyForm
  # Provides methods for rendering form elements and forms
  module Rendering
    def render_elements
      each_renderable_element do |element|
        if element.input_type == :hidden
          input(**element.input_html_attributes)
        else
          element.errors_messages.any? ? render_element_with_errors(element) : render_element(element)
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
      if %i[checkbox radio select textarea].include?(element.input_type)
        public_send("render_#{element.input_type}", element, **html_attributes)
      else
        input(**element.input_html_attributes, **html_attributes)
      end
    end

    def render_checkbox(element, **html_attributes) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      if element.class.select_options.any?
        element.class.select_options.each do |value, label_text|
          checkbox_id = "#{element.html_id}_#{value}"
          checkbox_attrs = element.input_html_attributes.merge(
            value: value,
            id: checkbox_id,
            name: "#{element.html_name}[]",
            checked: Array(element.value).include?(value)
          )

          input(**checkbox_attrs, **html_attributes)
          label(**element.label_html_attributes, for: checkbox_id) { label_text }
        end
      else
        input(name: element.html_name, type: "hidden", value: "0", autocomplete: "off")
        input(**element.input_html_attributes, type: "checkbox", value: "1", **html_attributes)
      end
    end

    def render_radio(element, **html_attributes)
      element.class.select_options.each do |value, label_text|
        label(**element.label_html_attributes) { label_text }
        input(**element.input_html_attributes, **html_attributes, type: "radio", value: value,
                                                                  checked: value == element.value)
      end
    end

    def render_select(element, **html_attributes)
      select(**element.input_html_attributes, **html_attributes) do
        element.class.select_options.each do |value, label_text|
          selected = if element.class.input_options[:multiple]
                       Array(element.value).include?(value)
                     else
                       value == element.value
                     end
          option(value: value, selected: selected) { label_text }
        end
      end
    end

    def render_textarea(element, **html_attributes)
      textarea(**element.input_html_attributes, **html_attributes) { element.value }
    end

    def render_errors(element)
      div(class: "error-messages") { element.errors_messages.join(", ") }
    end

    def render_form(**html_attributes, &block)
      form(**@html_options, **html_attributes, &block)
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
