module EasyForm
  class Element
    attr_reader :name, :input_options, :output_options, :value, :html_name, :html_id

    def initialize(name, value, parent_name: nil)
      @name = name
      @value = value
      @html_name = parent_name ? "#{parent_name}[#{name}]" : name
      @html_id = parent_name.to_s.split(/\[|\]/).reject(&:blank?).push(name).compact.join("_")
    end

    def input(**options)
      @input_options = options
    end

    def output(**options)
      @output_options = options
    end

    def markup(&block)
      if block
        @markup_block = block
      else
        @markup_block
      end
    end

    def html_attributes
      attrs = @input_options
      attrs[:name] ||= html_name
      attrs[:id] ||= html_id
      attrs[:value] ||= value
      attrs
    end
  end
end
