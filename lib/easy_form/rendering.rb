# frozen_string_literal: true

module EasyForm
  # Provides methods for rendering form elements and forms
  module Rendering
    def render_elements
      each_element(&method(:render_element))
    end

    def render_element(element)
      label(for: element.html_id) { element.label } if element.label
      if %i[checkbox radio select textarea].include?(element.input_options[:type].to_sym)
        public_send("render_#{element.input_options[:type]}", element)
      else
        render_input(element)
      end
    end

    def render_input(element)
      input(**element.html_attributes)
    end

    def render_checkbox(element) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      if element.select_options
        element.select_options.each do |value, label_text|
          checkbox_id = "#{element.html_id}_#{value}"
          checkbox_attrs = element.html_attributes.merge(
            value: value,
            id: checkbox_id,
            name: "#{element.html_name}[]",
            checked: Array(element.value).include?(value)
          )

          input(**checkbox_attrs)
          label(for: checkbox_id) { label_text }
        end
      else
        input(name: element.html_name, type: "hidden", value: "0", autocomplete: "off")
        input(**element.html_attributes.merge(type: "checkbox", value: "1"))
      end
    end

    def render_radio(element)
      element.select_options.each do |value, label_text|
        label(for: element.html_id) { label_text }
        input(**element.html_attributes.merge(type: "radio", value: value, checked: value == element.value))
      end
    end

    def render_select(element)
      select(**element.html_attributes) do
        element.select_options.each do |value, label_text|
          selected = if element.input_options[:multiple]
                       Array(element.value).include?(value)
                     else
                       value == element.value
                     end
          option(value: value, selected: selected) { label_text }
        end
      end
    end

    def render_textarea(element)
      textarea(**element.html_attributes) { element.value }
    end

    def render_form(&block)
      form(**{ method: html_method, action: html_action, "accept-charset" => "UTF-8" }.merge(@html_options)) do
        render_authenticity_token if respond_to?(:helpers)
        render_method_field
        render_elements
        yield if block
        render_submit
      end
    end

    def render_authenticity_token
      input(name: "authenticity_token", type: "hidden", value: helpers.form_authenticity_token)
    end

    def render_method_field
      input(name: "_method", type: "hidden", value: http_method)
    end

    def render_submit(**html_attributes)
      input(**{ name: "commit", type: "submit", value: submit_value }.merge(html_attributes))
    end

    private

    def submit_value
      "#{resource_action.to_s.capitalize} #{model_name}"
    end

    def resource_action
      @model.persisted? ? :update : :create
    end

    def http_method
      html_options[:method] ||= @model.persisted? ? "patch" : "post"
    end

    def html_action
      html_options[:action] ||= default_action
    end

    def html_method
      html_options[:method] = html_options[:method].to_s.downcase == "get" ? "get" : "post"
    end

    def default_action
      respond_to?(:helpers) ? helpers.url_for(action: resource_action) : "/"
    end
  end
end
