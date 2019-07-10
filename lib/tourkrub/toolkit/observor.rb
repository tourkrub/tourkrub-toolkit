module Tourkrub
  module Toolkit
    module Observor
      class IsNotObservable < StandardError; end;

      class << self 
        def included(base)
          base.extend(ClassMethod) 
        end
      end
      
      module ClassMethod
        def observe(on:, action:, reaction:)
          raise IsNotObservable, "#{on} is not supported" unless (on).is_a?(Class)

          on.class_variable_set("@@#{action}_observed_reaction", reaction)
          on.singleton_class.send(:alias_method, "#{action}_observed", action)
          on.instance_eval(
            <<-EOS
              def #{action}(*args)
                result = #{action}_observed(*args)
                self.class_variable_get(:@@#{action}_observed_reaction).call(result)
                result
              end
            EOS
          )
        end
      end
    end
  end
end
