# frozen_string_literal: true

module ActionForm
  # Collection of subforms that can be iterated and rendered
  class SubformsCollection < ::Phlex::HTML
    extend Forwardable
    include ActionForm::Rendering
    include ActionForm::Composition

    def_delegators :@subforms, :last, :first, :length, :size, :[], :<<

    attr_reader :subforms, :tags, :name
    attr_accessor :helpers

    class << self
      attr_accessor :default, :host_class, :subform_definition

      def subform(subform_class = nil, &block)
        @subform_definition ||= subform_class || Class.new(host_class.subform_class)
        @subform_definition.class_eval(&block) if block
      end

      def inherited(subclass)
        super
        subclass.subform_definition = subform_definition
        subclass.default = default
        subclass.host_class = host_class
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
        function actionFormAddSubform(event) {
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
        function actionFormRemoveSubform(event) {
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

    def view_template # rubocop:disable Metrics/AbcSize
      script(type: "text/javascript") { raw safe(remove_subform_js) }
      script(type: "text/javascript") { raw safe(add_subform_js) }
      subforms.each do |subform|
        subform.helpers = helpers
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
