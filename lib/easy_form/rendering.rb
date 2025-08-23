# frozen_string_literal: true

module EasyForm
  # Provides methods for rendering form elements and forms
  module Rendering
    def render_elements
      each_element(&method(:render_element))
    end

    def render_element(element)
      render_label(element)
      render_input(element)
    end

    def render_label(element)
      return if hide_label?(element)

      label(**element.label_html_attributes) { element.label_text }
    end

    def render_input(element)
      if %i[checkbox radio select textarea].include?(element.class.input_options[:type].to_sym)
        public_send("render_#{element.class.input_options[:type]}", element)
      else
        input(**element.input_html_attributes)
      end
    end

    def render_checkbox(element) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      if element.class.select_options.any?
        element.class.select_options.each do |value, label_text|
          checkbox_id = "#{element.html_id}_#{value}"
          checkbox_attrs = element.input_html_attributes.merge(
            value: value,
            id: checkbox_id,
            name: "#{element.html_name}[]",
            checked: Array(element.value).include?(value)
          )

          input(**checkbox_attrs)
          label(**element.label_html_attributes.merge(for: checkbox_id)) { label_text }
        end
      else
        input(name: element.html_name, type: "hidden", value: "0", autocomplete: "off")
        input(**element.input_html_attributes.merge(type: "checkbox", value: "1"))
      end
    end

    def render_radio(element)
      element.class.select_options.each do |value, label_text|
        label(**element.label_html_attributes) { label_text }
        input(**element.input_html_attributes.merge(type: "radio", value: value, checked: value == element.value))
      end
    end

    def render_select(element)
      select(**element.input_html_attributes) do
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

    def render_textarea(element)
      textarea(**element.input_html_attributes) { element.value }
    end

    def render_error_messages
      return unless errors.any?

      h2 do
        "#{helpers.pluralize(errors.count, "error")} prohibited this #{model_name.human.downcase} from being saved:"
      end
      ul do
        errors.full_messages.each do |message|
          li { message }
        end
      end
    end

    def render_form(&block)
      render_error_messages
      form(**{ method: html_method, action: html_action, "accept-charset" => "UTF-8" }.merge(@html_options)) do
        render_authenticity_token
        render_method_input
        yield if block
      end
    end

    def render_authenticity_token
      input(name: "authenticity_token", type: "hidden", value: helpers.form_authenticity_token)
    end

    def render_method_input
      input(name: "_method", type: "hidden", value: http_method)
    end

    def render_submit(**html_attributes)
      input(**{ name: "commit", type: "submit", value: submit_value }.merge(html_attributes))
    end

    private

    def submit_value
      "#{resource_action.to_s.capitalize} #{model_name}"
    end

    def hide_label?(element)
      return true unless element.class.label_options.first[:display]

      input_type = element.class.input_options[:type].to_sym
      input_type == :hidden || (%i[checkbox radio].include?(input_type) && element.class.select_options.any?)
    end
  end
end
