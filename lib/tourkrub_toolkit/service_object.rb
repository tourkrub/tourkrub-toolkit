# frozen_string_literal: true

require "dry-struct"

module TourkrubToolkit
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

      def declare_output(&block)
        const_set("Output", Class.new(Dry::Struct) do |klass|
          klass.instance_eval(&block)
        end)
      end

      def process(args)
        service = new
        begin
          service.assign_input(input_klass.new(args))
          service.process
          service.assign_output(output_klass.new(service.output))
        rescue StandardError => exception
          service.assign_error(exception)
        end
        service
      end

      def process!(args)
        process(args).tap { |service| raise service.error if service.error }
      end

      private

      def input_klass
        const_get("Input")
      end

      def output_klass
        const_get("Output")
      end
    end

    attr_reader :input, :error, :output

    def assign_input(input)
      @input = input
    end

    def assign_error(exception)
      @error = exception
    end

    def assign_output(output)
      @output = output
    end

    def success?
      error.nil?
    end
  end
end
