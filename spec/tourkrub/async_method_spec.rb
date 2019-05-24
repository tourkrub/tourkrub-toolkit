# frozen_string_literal: true

RSpec.describe Tourkrub::Toolkit::AsyncMethod do
  before(:all) do
    class TestAsyncMethod
      include Tourkrub::Toolkit::AsyncMethod

      def initialize(bar)
        @bar = bar
      end

      def foo(bar)
        @bar + bar
      end
    end
  end

  before(:each) do
    Sidekiq::Worker.clear_all
  end

  describe "#foofo" do
    it "raise error NoMethodError" do
      expect { TestAsyncMethod.new("bar").foofoo }.to raise_error(NoMethodError)
    end
  end

  describe "#_async" do
    context "fake sidekiq" do
      it "add job to a pool" do
        instance = TestAsyncMethod.new("bar")
        instance.foo_async("bar")

        expect(FooTestAsyncMethodWorker.jobs.size).to eq(1)
      end
    end

    context "inline sidekiq" do
      it "process job" do
        Sidekiq::Testing.inline! do
          instance = TestAsyncMethod.new("bar")
          instance.foo_async("bar")
        end

        expect(FooTestAsyncMethodWorker.jobs.size).to eq(0)
      end
    end
  end
end
