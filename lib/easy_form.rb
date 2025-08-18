# frozen_string_literal: true

require "phlex"
require "easy_params"
require_relative "easy_form/version"
require_relative "easy_form/dsl/configuration_block"
require_relative "easy_form/element"
require_relative "easy_form/base"

module EasyForm
  class Error < StandardError; end
end
