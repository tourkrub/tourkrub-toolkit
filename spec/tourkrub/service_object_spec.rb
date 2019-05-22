# frozen_string_literal: true

RSpec.describe Tourkrub::Toolkit::ServiceObject do
  before(:all) do
    class ServiceObjectSpec
      include Tourkrub::Toolkit::ServiceObject

      declare_input do
        attribute :value, Types::Strict::Integer
      end

      declare_output do
        attribute :data, Types::Strict::Integer
      end

      def process
        added_value = input.value + 1
        assign_output(data: added_value)
      end
    end
  end

  describe "#process" do
    context "with valid args" do
      it "return success? true" do
        service = ServiceObjectSpec.process(value: 1)

        expect(service.output.data).to eq(2)
        expect(service.success?).to be true
      end
    end

    context "with invalid args" do
      it "return success? false" do
        service = ServiceObjectSpec.process(1)

        expect(service.output).to be nil
        expect(service.success?).to be false
        expect(service.error.class).to eq(Dry::Struct::Error)
      end
    end
  end

  describe "#process!" do
    it "return success? true" do
      service = ServiceObjectSpec.process!(value: 1)

      expect(service.output.data).to eq(2)
      expect(service.success?).to be true
    end

    it "raise error" do
      allow_any_instance_of(ServiceObjectSpec)
        .to receive(:process).and_raise("oops")

      expect { ServiceObjectSpec.process!(value: 1) }
        .to raise_error(RuntimeError, "oops")
    end
  end
end
