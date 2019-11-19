# frozen_string_literal: true

require_relative "tourkrub_toolkit/version"

require_relative "tourkrub_toolkit/service_object"
require_relative "tourkrub_toolkit/service_assembly"
require_relative "tourkrub_toolkit/async_method"
require_relative "tourkrub_toolkit/observor"

module TourkrubToolkit
  class Error < StandardError; end
end
