# frozen_string_literal: true

# rubocop:disable Lint/ConstantDefinitionInBlock

require 'spec_helper'

RSpec.describe Turtle::EventNotificator, type: :module do
  describe '#included' do
    let(:klass) do
      class OrderClassMethods
        include Turtle::EventNotificator
      end
    end
    after { klass }

    it 'should extend ClassMethods' do
      expect(described_class).to receive(:included).and_call_original
      expect(Turtle::EventNotificator::ClassMethods).to receive(:extended)
    end
  end

  describe Turtle::EventNotificator::ClassMethods do
    describe '#act_as_notification' do
      class OrderClassMethods
        include Turtle::EventNotificator::ClassMethods
      end

      let(:order) { OrderClassMethods.new }
      subject { order.act_as_notification(options) }

      context 'without model name' do
        let(:options) { {} }

        it 'should raise an error' do
          expect { subject }.to raise_error(Turtle::EventNotificator::ModelRequiredError)
        end
      end

      context 'with model' do
        let(:model) { 'order' }

        context 'without states and actions' do
          let(:options) { { model: model } }

          it 'shouldnt call any callback behaviors' do
            expect(order).not_to receive(:initialize_event_notificator)
            expect(order).not_to receive(:build_event_notificator_options!)
            expect(order).not_to receive(:build_event_notificator_before_callback!)
            expect(order).not_to receive(:build_event_notificator_after_callback!)
            expect(order).not_to receive(:build_event_notificator_notify!)
            subject
          end
        end

        context 'with states and actions' do
          let(:options) { { model: model, states: %i[completed], actions: %i[completed] } }

          it 'shouldnt call all callback behaviors' do
            expect(order).to receive(:initialize_event_notificator)
            expect(order).to receive(:build_event_notificator_options!)
            expect(order).to receive(:build_event_notificator_before_callback!)
            expect(order).to receive(:build_event_notificator_after_callback!)
            expect(order).to receive(:build_event_notificator_after_touch_callback!)
            expect(order).to receive(:build_event_notificator_notify!)
            subject
          end

          context 'with error in builders' do
            before { allow(order).to receive(:initialize_event_notificator).and_raise(StandardError) }

            it 'should be nil' do
              is_expected.to be_nil
            end
          end
        end

        context 'with all params' do
          before do
            allow(order).to receive(:include)
            allow(order).to receive(:connection)
            allow(order).to receive(:before_create)
            allow(order).to receive(:before_update)
            allow(order).to receive(:before_destroy)
            allow(order).to receive(:after_create)
            allow(order).to receive(:after_update)
            allow(order).to receive(:after_destroy)
            allow(order).to receive(:after_commit)
          end

          let(:options) do
            {
              model: 'order',
              enveloped: true,
              serializer: OrderInstanceMethods,
              states: %i[pending completed],
              state_column: :state,
              actions: %i[created updated destroyed],
              rescue_errors: false,
              notify_rescued_error: false,
              delayed: %i[created updated destroyed]
            }
          end

          after { subject }

          it 'should invoke callbacks' do
            expect(order).to receive(:send).with(:include, Turtle::EventNotificator::InstanceMethods).once
            expect(order).to receive(:send).with('before_create', any_args).twice
            expect(order).to receive(:send).with('before_update', any_args).twice
            expect(order).to receive(:send).with('before_destroy', any_args).twice
            expect(order).to receive(:send).with('after_create', any_args).once
            expect(order).to receive(:send).with('after_update', any_args).once
            expect(order).to receive(:send).with('after_destroy', any_args).once
            expect(order).to receive(:send).with(:after_touch, any_args).once
            expect(order).to receive(:send).with(:after_commit, any_args).once
          end

          it 'should establish a connection' do
            expect(order).to receive(:connection).once
          end
        end
      end
    end
  end

  describe Turtle::EventNotificator::InstanceMethods do
    class OrderInstanceMethods
      include Turtle::EventNotificator::InstanceMethods

      def initialize(klass, options); end

      def as_json
        { hello: :world }
      end
    end

    describe '#event_notificator_options!' do
      let(:order) { OrderInstanceMethods.new(nil, {}) }
      before { subject }
      subject do
        order.event_notificator_options!(
          model: 'order',
          enveloped: true,
          serializer: OrderInstanceMethods,
          states: %i[pending completed],
          state_column: :state,
          actions: %i[create update destroy],
          rescue_errors: false,
          notify_rescued_error: false,
          delayed: %i[created updated destroyed]
        )
      end

      it 'should have options' do
        expect(order.event_notificator_options).to eq(
          enveloped: true,
          states: %i[pending completed],
          state_column: :state,
          serializer_options: {},
          actions: %i[create update destroy],
          rescue_errors: false,
          notify_rescued_error: false,
          continue_after_rescued_error: false,
          delayed: %i[created updated destroyed],
          model: 'order',
          serializer: OrderInstanceMethods
        )
      end

      it 'should have events' do
        expect(order.event_notificator_events.all? { |a| a.is_a?(Turtle::EventNotificator::Event) }).to be_truthy
      end
    end

    describe '#event_notificator_before_callback!' do
      let(:order) { OrderInstanceMethods.new(nil, {}) }
      before do
        allow(order).to receive(:state_was).and_return('processing')
        order.event_notificator_options!(
          model: 'order',
          enveloped: true,
          serializer: OrderInstanceMethods,
          states: %i[pending completed],
          state_column: :state,
          actions: %i[created updated destroyed],
          rescue_errors: false,
          notify_rescued_error: false,
          delayed: %i[created updated destroyed]
        )
        subject
      end
      subject { order.event_notificator_before_callback!(action) }

      context 'with create' do
        let(:action) { :create }

        it 'should have before callback' do
          expect(order.event_notificator_before_callback).to eq(state: 'processing', action: :created)
        end
      end

      context 'with updated' do
        let(:action) { :update }

        it 'should have before callback' do
          expect(order.event_notificator_before_callback).to eq(state: 'processing', action: :updated)
        end
      end

      context 'with updated' do
        let(:action) { :destroy }

        it 'should have before callback' do
          expect(order.event_notificator_before_callback).to eq(state: 'processing', action: :destroyed)
        end
      end
    end

    describe '#event_notificator_after_callback!' do
      let(:order) { OrderInstanceMethods.new(nil, {}) }
      before do
        allow(order).to receive(:state_was).and_return('processing')
        order.event_notificator_options!(
          model: 'order',
          enveloped: true,
          serializer: OrderInstanceMethods,
          states: %i[pending completed],
          state_column: :state,
          actions: %i[created updated],
          rescue_errors: false,
          notify_rescued_error: false,
          delayed: %i[created updated destroyed]
        )
        order.event_notificator_before_callback!(:update)
        subject
      end
      subject { order.event_notificator_after_callback!(action) }

      context 'with create' do
        let(:action) { :create }

        it 'should have after callback' do
          expect(order.event_notificator_after_callback).to eq(state: 'processing', action: :created)
        end

        it 'should have notification' do
          expect(order.event_notificator_notifications.compact.all? { |a| a.is_a?(Turtle::EventNotificator::Notification) })
            .to be_truthy
        end
      end

      context 'with updated' do
        let(:action) { :update }

        it 'should have after callback' do
          expect(order.event_notificator_after_callback).to eq(state: 'processing', action: :updated)
        end

        it 'should have notification' do
          expect(order.event_notificator_notifications.compact.all? { |a| a.is_a?(Turtle::EventNotificator::Notification) })
            .to be_truthy
        end
      end

      context 'with updated' do
        let(:action) { :destroy }

        it 'should have after callback' do
          expect(order.event_notificator_after_callback).to eq(state: 'processing', action: :destroyed)
        end

        it 'shouldnt have notification' do
          expect(order.event_notificator_notifications.empty?).to be_falsey
        end
      end
    end

    describe '#event_notificator_notify!' do
      let(:order) { OrderInstanceMethods.new(nil, {}) }
      before do
        allow(order).to receive(:state_was).and_return('processing')
        allow(order).to receive(:payload!).and_return(hello: :world)
        order.event_notificator_options!(
          model: 'order',
          enveloped: true,
          serializer: OrderInstanceMethods,
          serializer_options: { root: false },
          serializer_root: :data,
          states: %i[pending completed],
          state_column: :state,
          actions: %i[created updated destroyed],
          rescue_errors: false,
          notify_rescued_error: false,
          delayed: %i[created updated destroyed]
        )
        order.event_notificator_before_callback!(:update)
        order.event_notificator_after_callback!(:update)
      end

      subject { order.event_notificator_notify! }

      context 'when dont have notifications' do
        before { allow(order).to receive(:event_notificator_notifications).and_return([]) }

        it 'shouldnt publish anything' do
          expect_any_instance_of(Turtle::EventNotificator::Notification).not_to receive(:publish!)
          subject
        end

        it 'should clear event notificator accessors' do
          expect(order.event_notificator_before_callback).not_to be_nil
          expect(order.event_notificator_after_callback).not_to be_nil
          expect(order.event_notificator_notifications.empty?).to be_truthy
          subject
          expect(order.event_notificator_before_callback).to be_nil
          expect(order.event_notificator_after_callback).to be_nil
          expect(order.event_notificator_notifications.empty?).to be_truthy
        end

        it 'shouldnt publish anything' do
          expect_any_instance_of(Turtle::EventNotificator::Notification).not_to receive(:publish!)
          subject
        end
      end

      context 'when have notifications' do
        it 'should clear event notificator accessors' do
          expect(order.event_notificator_before_callback).not_to be_nil
          expect(order.event_notificator_after_callback).not_to be_nil
          expect(order.event_notificator_notifications.empty?).to be_falsey
          expect_any_instance_of(Turtle::EventNotificator::Notification).to receive(:publish!)
            .exactly(order.event_notificator_notifications.compact.length)
          subject
          expect(order.event_notificator_before_callback).to be_nil
          expect(order.event_notificator_after_callback).to be_nil
          expect(order.event_notificator_notifications.empty?).to be_truthy
        end

        it 'should call to build payload' do
          expect(order).to receive(:build_event_notificator_payload).once.and_call_original
          expect(order).to receive(:event_notificator_serializer).once.and_call_original
          expect_any_instance_of(Turtle::EventNotificator::Notification).to receive(:publish!)
            .exactly(order.event_notificator_notifications.compact.length)
          subject
        end

        it 'shouldnt publish for each notification' do
          expect_any_instance_of(Turtle::EventNotificator::Notification).to receive(:publish!)
            .exactly(order.event_notificator_notifications.compact.length)
          subject
        end
      end
    end

    describe '#__build_state_value__' do
      subject { order.__build_state_value__ }

      before do
        order.event_notificator_options!(
          model: 'order',
          enveloped: true,
          serializer: OrderInstanceMethods,
          serializer_options: { root: false },
          serializer_root: :data,
          states: %i[pending completed],
          state_column: :state,
          actions: %i[created updated destroyed],
          rescue_errors: false,
          notify_rescued_error: false,
          delayed: %i[created updated destroyed]
        )
      end

      let(:order) { OrderInstanceMethods.new(nil, {}) }

      context 'without state_was' do
        it { is_expected.to be_nil }
      end

      context 'with state_was' do
        before { allow(order).to receive(:state_was).and_return('canceled') }

        it { is_expected.to eq('canceled') }
      end
    end
  end
end
# rubocop:enable Lint/ConstantDefinitionInBlock
