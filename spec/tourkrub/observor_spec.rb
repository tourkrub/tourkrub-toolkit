# frozen_string_literal: true

RSpec.describe Tourkrub::Toolkit::Observor do
  before do
    class FooBarReaction
      def self.baz(arg)
        "baz#{arg}"
      end
    end

    class FooObservable
      def self.bar
        "boo"
      end
    end

    class ObservorSpec
      include Tourkrub::Toolkit::Observor

      observe on: FooObservable, action: "bar", reaction: proc { |result| FooBarReaction.baz(result) }
    end
  end

  describe "#observe" do
    it "should execute reaction" do
      expect(FooBarReaction).to receive(:baz).with("boo")

      result = FooObservable.bar

      expect(result).to eq("boo")
    end
  end

  context "observe instance" do
    describe "#observe" do
      it "should raise" do
        expect{
          class ObservorSpec
            include Tourkrub::Toolkit::Observor

            observe on: FooObservable.new, action: "bar", reaction: proc { |result| FooBarReaction.baz(result) }
          end
        }.to raise_error(Tourkrub::Toolkit::Observor::IsNotObservable)
      end
    end
  end
end
