module TourkrubToolkit
  module Observor
    class IsNotObservable < StandardError; end

    class << self
      def included(base)
        base.extend(ClassMethod)
      end

      def disable!
        @disable = true
      end

      def disabled?
        @disable
      end
    end

    module ClassMethod
      def observe(on:, action:, reaction: nil)
        return if TourkrubToolkit::Observor.disabled?
        raise IsNotObservable, "#{on} is not supported" unless on.is_a?(Class)

        if block_given?
          on.class_variable_set("@@#{action}_observed_reaction", proc { |result| yield(result) })
        else
          on.class_variable_set("@@#{action}_observed_reaction", reaction)
        end
        on.singleton_class.send(:alias_method, "#{action}_observed", action)
        on.instance_eval(<<-DEF, __FILE__, __LINE__ + 1)
          def #{action}(*args)
            result = #{action}_observed(*args)
            self.class_variable_get(:@@#{action}_observed_reaction).call(result)
            result
          end
        DEF
      end
    end
  end
end
