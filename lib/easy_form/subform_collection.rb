# frozen_string_literal: true

module EasyForm
  # Collection of subforms that can be iterated and rendered
  class SubformCollection
    def initialize(&block)
      @subforms = block ? block.call : []
    end

    def each(&block)
      return to_enum(:each) unless block

      @subforms.each(&block)
    end

    def <<(value)
      @subforms << value
    end

    def render?
      true
    end
  end
end
