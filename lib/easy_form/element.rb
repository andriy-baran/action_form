# frozen_string_literal: true

module EasyForm
  # Represents a form element with input/output configuration and HTML attributes
  # rubocop:disable Metrics/ClassLength
  class Element
    attr_reader :name, :input_options, :output_options, :html_name, :html_id, :select_options, :tags, :errors_messages

    def initialize(name, object, parent_name: nil)
      @name = name
      @object = object
      @html_name = build_html_name(name, parent_name)
      @html_id = build_html_id(name, parent_name)
      @tags = self.class.tags_list.dup
      @errors_messages = extract_errors_messages(object, name)
      tags.merge!(errors: errors_messages.any?)
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

      def tags_list
        @tags_list ||= {}
      end

      def input(type:, **options)
        @input_options = { type: type }.merge(options)
        tags_list.merge!(input: type)
      end

      def output(type:, **options)
        @output_options = { type: type }.merge(options)
        tags_list.merge!(output: type)
      end

      def options(collection)
        @select_options = collection
        tags_list.merge!(options: true)
      end

      def label(text: nil, display: true, **html_options)
        @label_options = [{ text: text, display: display }, html_options]
      end

      def tags(**tags_list)
        tags_list.merge!(tags_list)
      end
    end

    def label_text
      self.class.label_options.first[:text] || name.to_s.tr("_", " ").capitalize
    end

    def label_html_attributes
      { for: html_id }.merge(self.class.label_options.last)
    end

    def html_value # rubocop:disable Metrics/MethodLength
      if input_type == :checkbox
        value ? "1" : "0"
      elsif detached?
        self.class.input_options[:value]
      elsif !input_tag?
        nil
      elsif object.is_a?(EasyParams::Base)
        object.public_send(name)
      else
        value.to_s
      end
    end

    def html_checked
      if input_type == :checkbox
        value
      elsif input_type == :radio
        value == html_value
      end
    end

    def input_html_attributes # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
      attrs = self.class.input_options.dup
      attrs.delete(:type) unless input_tag?
      attrs[:name] ||= html_name
      attrs[:id] ||= html_id
      attrs[:value] ||= html_value
      attrs[:checked] ||= html_checked
      attrs[:disabled] ||= disabled?
      attrs[:readonly] ||= readonly?
      attrs
    end

    def value
      return unless object

      object.public_send(name)
    end

    def render?
      true
    end

    def detached?
      false
    end

    def disabled?
      false
    end

    def readonly?
      false
    end

    def input_type
      self.class.input_options[:type].to_sym
    end

    private

    attr_reader :object

    def input_tag?
      !%i[select textarea].include?(input_type)
    end

    def build_html_name(name, parent_name)
      parent_name ? "#{parent_name}[#{name}]" : name
    end

    def build_html_id(name, parent_name)
      parent_name.to_s.split(/\[|\]/).reject(&:blank?).push(name).compact.join("_")
    end

    def extract_errors_messages(object, name)
      (object.respond_to?(:errors) && object&.errors&.messages_for(name)) || []
    end
  end
  # rubocop:enable Metrics/ClassLength
end
