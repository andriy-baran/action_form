# frozen_string_literal: true

require "phlex"
require "easy_params"
require_relative "easy_form/version"
require_relative "easy_form/dsl/configuration_block"
require_relative "easy_form/input"
require_relative "easy_form/inputs"
require_relative "easy_form/base"
require_relative "easy_form/element"
require_relative "easy_form/inputs/checkbox"
require_relative "easy_form/inputs/label"
require_relative "easy_form/inputs/radio"
require_relative "easy_form/inputs/password"
require_relative "easy_form/inputs/email"
require_relative "easy_form/inputs/telephone"
require_relative "easy_form/inputs/url"
require_relative "easy_form/inputs/textarea"
require_relative "easy_form/inputs/hidden"
require_relative "easy_form/inputs/number"
require_relative "easy_form/inputs/range"
require_relative "easy_form/inputs/search"
require_relative "easy_form/inputs/color"
require_relative "easy_form/inputs/date"
require_relative "easy_form/inputs/time"
require_relative "easy_form/inputs/datetime_local"
require_relative "easy_form/inputs/month"
require_relative "easy_form/inputs/week"
require_relative "easy_form/inputs/text"

module EasyForm
  class Error < StandardError; end
end
