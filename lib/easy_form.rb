# frozen_string_literal: true

require "phlex"
require "easy_params"
require_relative "easy_form/version"
require_relative "easy_form/schema_dsl"
require_relative "easy_form/rendering"
require_relative "easy_form/element"
require_relative "easy_form/base"

module EasyForm
  class Error < StandardError; end
end
