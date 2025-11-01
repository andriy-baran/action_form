# frozen_string_literal: true

require "phlex"
require "easy_params"
require "forwardable"
require_relative "action_form/version"
require_relative "action_form/composition"
require_relative "action_form/schema_dsl"
require_relative "action_form/elements_dsl"
require_relative "action_form/input"
require_relative "action_form/rendering"
require_relative "action_form/subform"
require_relative "action_form/subforms_collection"
require_relative "action_form/element"
require_relative "action_form/base"
require_relative "action_form/rails/rendering"
require_relative "action_form/rails/subform"
require_relative "action_form/rails/base"

module ActionForm
  class Error < StandardError; end
end
