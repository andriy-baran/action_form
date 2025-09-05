# frozen_string_literal: true

module EasyForm
  # Collection of subforms that can be iterated and rendered
  class SubformsCollection
    extend Forwardable

    def_delegators :@subforms, :last, :first, :length, :size, :[], :<<

    attr_reader :subforms, :tags, :name

    def self.of(subform_class)
      @subform_definition = subform_class
      self
    end

    class << self
      attr_reader :subform_definition
    end

    def initialize(name, &block)
      @name = name
      @subforms = block ? block.call : []
      @tags = {}
    end

    def each(&block)
      return to_enum(:each) unless block

      @subforms.each(&block)
    end

    def render?
      true
    end

    def template_html_id
      "#{name}_template"
    end
  end
end
