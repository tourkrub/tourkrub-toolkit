# frozen_string_literal: true

RSpec.describe Tourkrub::Toolkit::ServiceAssembly do
  before(:all) do
    class AddoneServiceObjectSpec
      include Tourkrub::Toolkit::ServiceObject

      declare_input do
        attribute :value, Types::Strict::Integer
        attribute :extra_id, Types::Strict::String.optional.default(nil)
      end

      declare_output do
        attribute :added_value, Types::Strict::Integer
      end

      def process
        added_value = input.value + 1
        assign_output(added_value: added_value)
      end
    end

    class SumAllServiceAssemblySpec
      include Tourkrub::Toolkit::ServiceAssembly

      declare_input do
        attribute :start_value, Types::Strict::Integer
        attribute :context, Types::Strict::Hash.optional.default(nil)
      end

      declare_output do
        attribute :end_value, Types::Strict::Integer
      end

      station AddoneServiceObjectSpec, value: :start_value
      station AddoneServiceObjectSpec, value: :added_value
      station AddoneServiceObjectSpec, value: :added_value, extra_id: :context_extra_id

      finish_with end_value: :added_value
    end

    class ToBreakServiceAssemblySpec
      include Tourkrub::Toolkit::ServiceAssembly

      declare_input do
        attribute :start_value, Types::Strict::Integer
        attribute :context, Types::Strict::Hash.optional.default(nil)
      end

      declare_output do
        attribute :end_value, Types::Strict::Integer
      end

      station AddoneServiceObjectSpec, value: 1

      finish_with end_value: :added_value
    end
  end

  describe "#process" do
    it "return correct output" do
      service = SumAllServiceAssemblySpec.process!(start_value: 1, context: { extra_id: "1" })

      expect(service.output.end_value).to eq(4)
    end

    it "return error" do
      allow_any_instance_of(AddoneServiceObjectSpec)
        .to receive(:process).and_raise("oops")

      service = SumAllServiceAssemblySpec.process(start_value: 1, context: { extra_id: "1" })

      expect(service.success?).to eq(false)
      expect(service.error.class).to eq(RuntimeError)
    end
  end

  describe "#process!" do
    it "raise" do
      allow_any_instance_of(AddoneServiceObjectSpec)
        .to receive(:process).and_raise("oops")

      expect { SumAllServiceAssemblySpec.process!(start_value: 1, context: { extra_id: "1" }) }
        .to raise_error(RuntimeError, "oops")
    end

    context "invalid station argrument" do
      it "raise error" do
        expect { ToBreakServiceAssemblySpec.process!(start_value: 1, context: { extra_id: "1" }) }
          .to raise_error(ArgumentError, "Station accepts only Symbol, use :context_foo_bar for static value")
      end
    end
  end
end
