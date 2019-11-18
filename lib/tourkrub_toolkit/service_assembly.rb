require_relative "service_object"

module TourkrubToolkit
  module ServiceAssembly
    class << self
      def included(base)
        base.extend ClassMethod
        base.include TourkrubToolkit::ServiceObject
        base.include InstanceMethod
      end
    end

    module ClassMethod
      def stations
        @stations ||= []
      end

      def station(service_object, args)
        stations << { service_object => args }
      end

      def finish_args
        @finish_args
      end

      def finish_with(finish_args)
        @finish_args = finish_args
      end
    end

    module InstanceMethod
      def process
        last_output = self.class.stations.inject(input) do |input, station|
          service_klass = station.keys[0]
          raw_args = station.values[0]
          args = map_input(input, raw_args)

          service = service_klass.process(args)

          raise service.error unless service.success?

          service.output
        end

        assign_output(map_output(last_output, self.class.finish_args))
      end

      private

      def map_input(input, raw_args)
        {}.tap do |args|
          raw_args.each do |key, value|
            args[key] = get_value(input, value)
          end
        end
      end

      def get_value(input, value)
        case value.class.name
        when "Symbol"
          value.to_s.include?("context_") ? @input.context[value.to_s.gsub("context_", "").to_sym] : input.send(value)
        when "Proc"
          value.call(input)
        else
          raise ArgumentError, "Station accepts only Symbol or Proc, use :context_foo_bar for static value"
        end
      end

      alias map_output map_input
    end
  end
end
