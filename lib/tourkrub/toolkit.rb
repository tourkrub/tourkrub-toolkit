# frozen_string_literal: true

require_relative "toolkit/version"

require_relative "toolkit/service_object"
require_relative "toolkit/service_assembly"
require_relative "toolkit/async_method"
require_relative "toolkit/observor"

module Tourkrub
  module Toolkit
    class Error < StandardError; end
  end
end
