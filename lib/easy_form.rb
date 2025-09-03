# frozen_string_literal: true

require "phlex"
require "easy_params"
require_relative "easy_form/version"
require_relative "easy_form/schema_dsl"
require_relative "easy_form/elements_dsl"
require_relative "easy_form/input"
require_relative "easy_form/rendering"
require_relative "easy_form/subform"
require_relative "easy_form/subform_collection"
require_relative "easy_form/element"
require_relative "easy_form/base"
require_relative "easy_form/rails/rendering"
require_relative "easy_form/rails/subform"
require_relative "easy_form/rails/base"

module EasyForm
  class Error < StandardError; end
end
