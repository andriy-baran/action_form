# frozen_string_literal: true

module ActionForm
  # Base class for parameter validation that is associated with form classes.
  # Provides functionality to create form instances from validated parameters.
  class Params < EasyParams::Base
    class << self
      attr_accessor :form_class

      def inherited(subclass)
        super
        subclass.form_class = form_class
      end
    end

    def create_form(scope: self.class.form_class.scope, **html_options)
      self.owner = self.class.form_class.new(params: self, scope: scope, **html_options)
    end
  end
end
