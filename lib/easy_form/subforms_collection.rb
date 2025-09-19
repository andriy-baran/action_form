# frozen_string_literal: true

module EasyForm
  # Collection of subforms that can be iterated and rendered
  class SubformsCollection
    extend Forwardable

    def_delegators :@subforms, :last, :first, :length, :size, :[], :<<

    attr_reader :subforms, :tags, :name

    class << self
      attr_reader :subform_definition
      attr_accessor :default

      def of(subform_class)
        @subform_definition = subform_class
        self
      end
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

    def add_subform_js
      <<~JS
        function easyFormAddSubform(event) {
          event.preventDefault()
          var template = document.querySelector("##{template_html_id}")
          const content = template.innerHTML.replace(/NEW_RECORD/g, new Date().getTime().toString())
          var beforeElement = event.target.closest(event.target.dataset.insertBeforeSelector)
          if (beforeElement) {
            beforeElement.insertAdjacentHTML("beforebegin", content)
          } else {
            event.target.parentElement.insertAdjacentHTML("beforebegin", content)
          }
        }
      JS
    end

    def remove_subform_js
      <<~JS
        function easyFormRemoveSubform(event) {
          event.preventDefault()
          var subform = event.target.closest(".new_#{name}")
          if (subform) { subform.remove() }
          var subform = event.target.closest(".#{name}_subform")
          if (subform) {
            subform.style.display = "none"
            var input = subform.querySelector("input[name*='_destroy']")
            if (input) { input.value = "1" }
          }
        }
      JS
    end
  end
end
