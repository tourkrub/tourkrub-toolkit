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

      def bar
        puts "Shoule not reach this line"
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

    context "complex payload" do
      it "should work properly" do
        large_object = OpenStruct.new(
          originator: OpenStruct.new(
            on: "user.reset_password_requested",
            request: { "message" => { "id" => 2742, "email" => "trin.p@tourkrub.co", "created_at" => "2019-05-31 18:22:30 +0700", "updated_at" => "2019-06-28 14:07:35 +0700", "name" => "", "contact_number" => "", "birth_date" => nil, "avatar" => { "url" => "fallback/263x263.gif", "normal" => { "url" => "fallback/263x263.gif" } }, "topic_arn" => nil, "phone" => nil, "first_name" => "", "last_name" => "" }, "meta" => { "app" => "tourkrub", "token" => "7p-QXSyHokF7osB5BjpH" } },
            event: "user.reset_password_requested",
            message: { "id" => 2742, "email" => "trin.p@tourkrub.co", "created_at" => "2019-05-31 18:22:30 +0700", "updated_at" => "2019-06-28 14:07:35 +0700", "name" => "", "contact_number" => "", "birth_date" => nil, "avatar" => { "url" => "fallback/263x263.gif", "normal" => { "url" => "fallback/263x263.gif" } }, "topic_arn" => nil, "phone" => nil, "first_name" => "", "last_name" => "" },
            meta: { "app" => "tourkrub", "token" => "7p-QXSyHokF7osB5BjpH" },
            from_agent: true
          ),
          method_string: "reset_password_requested",
          args: []
        )
        Sidekiq::Testing.inline! do
          instance = TestAsyncMethod.new(large_object)
          expect { instance.bar_async }.not_to raise_error
        end
      end
    end
  end
end
