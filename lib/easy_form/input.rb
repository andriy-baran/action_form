# frozen_string_literal: true

module EasyForm
  # Represents a form element with input/output configuration and HTML attributes
  class Input < Phlex::HTML
    attr_reader :element, :html_attributes

    def initialize(element, **html_attributes)
      super()
      @element = element
      @html_attributes = html_attributes
    end

    def view_template
      if %i[checkbox radio select textarea].include?(element.input_type)
        send("render_#{element.input_type}")
      else
        input(**mix(element.input_html_attributes, html_attributes))
      end
    end

    private

    def render_checkbox # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      if element.class.select_options.any?
        element.class.select_options.each do |value, label_text|
          checkbox_id = "#{element.html_id}_#{value}"
          checkbox_attrs = element.input_html_attributes.merge(
            value: value,
            id: checkbox_id,
            name: "#{element.html_name}[]",
            checked: Array(element.value).include?(value)
          )

          input(**mix(checkbox_attrs, html_attributes))
          label(**element.label_html_attributes, for: checkbox_id) { label_text }
        end
      else
        input(name: element.html_name, type: "hidden", value: "0", autocomplete: "off")
        input(**mix(element.input_html_attributes, html_attributes), type: "checkbox", value: "1")
      end
    end

    def render_radio
      element.class.select_options.each do |value, label_text|
        label(**element.label_html_attributes) { label_text }
        input(**mix(element.input_html_attributes, html_attributes), type: "radio", value: value,
                                                                     checked: value == element.value)
      end
    end

    def render_select
      select(**mix(element.input_html_attributes, html_attributes)) do
        element.class.select_options.each do |value, label_text|
          option(value: value, selected: option_selected?(value)) { label_text }
        end
      end
    end

    def render_textarea
      textarea(**mix(element.input_html_attributes, html_attributes)) { element.value }
    end

    def option_selected?(value)
      if element.class.input_options[:multiple]
        Array(element.value).include?(value)
      else
        value == element.value
      end
    end
  end
end
