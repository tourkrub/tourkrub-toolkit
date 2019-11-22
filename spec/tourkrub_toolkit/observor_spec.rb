# frozen_string_literal: true

RSpec.describe TourkrubToolkit::Observor do
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
  end

  context "passing reaction" do
    describe "#observe" do
      before do
        class ObservorSpec
          include TourkrubToolkit::Observor

          observe on: FooObservable, action: "bar", reaction: proc { |result| FooBarReaction.baz(result) }
        end
      end

      it "should execute reaction" do
        expect(FooBarReaction).to receive(:baz).with("boo")

        result = FooObservable.bar

        expect(result).to eq("boo")
      end
    end
  end

  context "passing block" do
    describe "#observe" do
      before do
        class ObservorSpec
          include TourkrubToolkit::Observor

          observe on: FooObservable, action: "bar" do |result|
            FooBarReaction.baz(result)
          end
        end
      end

      it "should execute reaction" do
        expect(FooBarReaction).to receive(:baz).with("boo")

        result = FooObservable.bar

        expect(result).to eq("boo")
      end
    end
  end

  context "observe instance" do
    describe "#observe" do
      it "should raise" do
        expect  do
          class ObservorSpec
            include TourkrubToolkit::Observor

            observe on: FooObservable.new, action: "bar", reaction: proc { |result| FooBarReaction.baz(result) }
          end
        end.to raise_error(TourkrubToolkit::Observor::IsNotObservable)
      end
    end
  end

  context "disabled" do
    before do
      TourkrubToolkit::Observor.disable!

      class ObservorSpec
        include TourkrubToolkit::Observor

        observe on: FooObservable, action: "bar" do |result|
          FooBarReaction.baz(result)
        end
      end
    end

    describe "#observe" do
      it "should not work" do
        expect(FooBarReaction).not_to receive(:baz).with("boo")

        result = FooObservable.bar

        expect(result).to eq("boo")
      end
    end
  end
end
