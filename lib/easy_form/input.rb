module EasyForm
  class Input
    attr_reader :name

    def initialize(name, &block)
      @name = name
      instance_eval(&block)
    end

    def html(&block)
      @html = DSL::ConfigurationBlock.new(&block)
    end

    def output(&block)
      @output = DSL::ConfigurationBlock.new(&block)
    end

    def markup(&block)
      if block
        @markup_block = block
      else
        @markup_block
      end
    end

    def attributes
      {
        html: @html.to_h,
        output: @output.to_h,
        markup: @markup_block
      }
    end
  end
end
