# frozen_string_literal: true

module EasyForm
  module Rails
    # Rendering module for EasyForm Rails integration that provides form rendering functionality.
    # Handles rendering of forms with error messages, authenticity tokens, UTF-8 encoding,
    # and other Rails-specific form requirements. Also provides helper methods for rendering
    # submit buttons and form elements.
    module Rendering
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
        form(**{ method: html_method, action: html_action, "accept-charset" => "UTF-8" }, **@html_options) do
          render_utf8_input
          render_authenticity_token
          render_method_input
          yield if block
        end
      end

      def render_authenticity_token
        input(name: "authenticity_token", type: "hidden", value: helpers.form_authenticity_token)
      end

      def render_method_input
        input(name: "_method", type: "hidden", value: http_method, autocomplete: "off")
      end

      def render_utf8_input
        input(name: "utf8", type: "hidden", value: "✓", autocomplete: "off")
      end

      def render_submit(**html_attributes)
        input(name: "commit", type: "submit", value: submit_value, **html_attributes)
      end

      private

      def submit_value
        "#{resource_action.to_s.capitalize} #{model_name}"
      end
    end
  end
end
