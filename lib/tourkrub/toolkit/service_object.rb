# frozen_string_literal: true

require "dry-struct"

module Tourkrub
  module Toolkit
    module ServiceObject
      module Types
        include Dry::Types()
      end

      class << self
        def included(base)
          base.extend ClassMethod
        end
      end

      module ClassMethod
        def declare_input(&block)
          const_set("Input", Class.new(Dry::Struct) do |klass|
            klass.instance_eval(&block)
          end)
        end

        def process(args)
          service = new
          begin
            service.add_input(input_klass.new(args))
            service.process
          rescue StandardError => exception
            service.add_error(exception)
          end
          service
        end

        def process!(args)
          process(args).tap { |service| raise service.error if service.error }
        end

        def input_klass
          const_get("Input")
        end
      end

      attr_reader :input, :error, :result

      def add_input(input)
        @input = input
      end

      def add_error(exception)
        @error = exception
      end

      def add_result(result)
        @result = result
      end

      def success?
        @error.nil?
      end
    end
  end
end
