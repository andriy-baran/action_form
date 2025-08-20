# frozen_string_literal: true

module EasyForm
  # Represents a form element with input/output configuration and HTML attributes
  class Element
    attr_reader :name, :input_options, :output_options, :html_name, :html_id, :select_options
    attr_accessor :value

    def initialize(name, value, parent_name: nil)
      @name = name
      @value = value
      @html_name = parent_name ? "#{parent_name}[#{name}]" : name
      @html_id = parent_name.to_s.split(/\[|\]/).reject(&:blank?).push(name).compact.join("_")
    end

    class << self
      def label_options
        @label_options ||= [{ text: nil, display: true }, {}]
      end

      def select_options
        @select_options ||= []
      end

      def output_options
        @output_options ||= {}
      end

      def input_options
        @input_options ||= {}
      end

      def input(type:, **options)
        @input_options = { type: type }.merge(options)
      end

      def output(type:, **options)
        @output_options = { type: type }.merge(options)
      end

      def options(collection)
        @select_options = collection
      end

      def label(text: nil, display: true, **html_options)
        @label_options = [{ text: text, display: display }, html_options]
      end
    end

    def label_text
      self.class.label_options.first[:text] || name.to_s.tr("_", " ").capitalize
    end

    def label_html_attributes
      { for: html_id }.merge(self.class.label_options.last)
    end

    def html_value
      if self.class.input_options[:type].to_sym == :checkbox
        value ? "1" : "0"
      elsif !input_tag?
        nil
      else
        value.to_s
      end
    end

    def html_checked
      if self.class.input_options[:type].to_sym == :checkbox
        value
      elsif self.class.input_options[:type].to_sym == :radio
        value == html_value
      end
    end

    def input_html_attributes
      attrs = self.class.input_options.dup
      attrs.delete(:type) unless input_tag?
      attrs[:name] ||= html_name
      attrs[:id] ||= html_id
      attrs[:value] ||= html_value
      attrs[:checked] ||= html_checked
      attrs
    end

    private

    def input_tag?
      !%i[select textarea].include?(self.class.input_options[:type].to_sym)
    end
  end
end
