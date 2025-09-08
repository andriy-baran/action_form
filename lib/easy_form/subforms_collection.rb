# frozen_string_literal: true

module EasyForm
  # Collection of subforms that can be iterated and rendered
  class SubformsCollection < ::Phlex::HTML
    extend Forwardable
    include EasyForm::Rendering

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

    def initialize(name)
      super()
      @name = name
      @subforms = []
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

    def view_template
      script(type: "text/javascript") { raw safe(remove_subform_js) }
      script(type: "text/javascript") { raw safe(add_subform_js) }
      subforms.each do |subform|
        if subform.tags[:template]
          render_subform_template(subform)
        else
          div(id: subform.html_id, class: subform.html_class) { render_subform(subform) }
        end
      end
    end

    def render_subform_template(subform)
      template(id: template_html_id) do
        div(class: "new_#{name}") { render_subform(subform) }
      end
    end
  end
end
