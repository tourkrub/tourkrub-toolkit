require "byebug"
require "sidekiq"

module Tourkrub
  module Toolkit
    module AsyncMethod
      class << self
        def included(base)
          base.include(InstanceMethod)
        end
      end

      module InstanceMethod
        private

        def method_missing(method_name, *args, &block)
          method_string = method_name.to_s

          if async_method?(method_string)
            Agent.do_async(self, method_string, *args)
          else
            super
          end
        end

        def respond_to_missing?(method_name, include_private = false)
          async_method?(method_name) || super
        end

        def async_method?(method_name)
          method_name.to_s.end_with?("_async")
        end
      end

      class Worker
        include Sidekiq::Worker

        def perform(dumped_agent)
          agent = Marshal.load(dumped_agent) # rubocop:disable Security/MarshalLoad
          agent.do
        end
      end

      class Agent
        class << self
          def do_async(originator, method_string, *args)
            new(originator, method_string, *args).do_async
          end
        end

        attr_reader :originator, :method_string, :args

        def initialize(originator, method_string, *args)
          @originator = originator
          @method_string = method_string
          @args = *args
        end

        def do_async
          worker.perform_async(dumped_self)
        end

        def do
          originator.send(original_method, *args)
        end

        private

        def original_method
          method_string.gsub("_async", "")
        end

        def worker_name
          unless @worker_name
            string = original_method.split("_").map(&:capitalize).join("")
            @worker_name = "#{string}#{originator.class.name}Worker"
          end

          @worker_name
        end

        def worker
          @worker ||= if Object.const_defined?(worker_name)
                        Object.const_get(worker_name)
                      else
                        Object.const_set(worker_name, Class.new(Worker))
                      end
        end

        def dumped_self
          Marshal.dump(self)
        end
      end
    end
  end
end
