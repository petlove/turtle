# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Turtle::EventNotificator::Notification, type: :model do
  describe '#initialize' do
    subject { described_class.new(event) }

    context 'with event' do
      let(:event) { :completed }

      it 'should have a event' do
        expect(subject.event).to eq(event)
      end
    end

    context 'without event' do
      let(:event) { nil }

      it 'should be nil the event' do
        expect(subject.event).to be_nil
      end
    end
  end

  describe '#publish!' do
    let(:notification) { described_class.new(:completed) }
    before { allow(notification).to receive(:as_json).and_return(event: notification.event) }
    subject { notification.publish!(notification, options) }

    context 'when publish raise an error' do
      before { allow(Turtle).to receive(:publish!).and_raise(StandardError, 'Turtle publish error :(') }

      context 'when rescue errors isnt enabled' do
        let(:options) { { rescue_errors: false } }

        it 'should raise an error' do
          expect { subject }.to raise_error(StandardError, 'Turtle publish error :(')
        end
      end

      context 'when rescue errors is enabled' do
        let(:options) { { rescue_errors: true } }

        it 'should raise an error' do
          is_expected.to be_nil
        end

        context 'when notify rescued error isnt enabled' do
          let(:options) { { rescue_errors: true, notify_rescued_error: false } }

          it 'shouldnt notify through' do
            expect(Honeybadger).not_to receive(:notify)
            subject
          end
        end

        context 'when notify rescued error is enabled' do
          let(:options) { { rescue_errors: true, notify_rescued_error: true } }

          it 'shouldnt notify through' do
            expect(Honeybadger).to receive(:notify).once
            subject
          end
        end
      end
    end

    context 'when publish with succes' do
      before do
        ENV['APP_NAME'] = 'turtle'
        ENV['APP_ENV'] = 'production'
      end

      context 'without delayed name equals the notification event' do
        let(:options) { { model: 'order', delayed: %i[pending] } }

        it 'shouldnt use delay on publishing' do
          expect(Turtle).to receive(:publish!).with(
            { name: 'event_order', prefix: 'turtle', environment: 'production', suffix: notification.event },
            notification,
            delayed: nil, event: nil, model: nil
          ).once
          subject
        end
      end

      context 'with delayed name equals the notification event' do
        let(:options) { { model: 'order', delayed: %i[completed] } }

        it 'shouldnt use delay on publishing' do
          expect(Turtle).to receive(:publish!).with(
            { name: 'event_order', prefix: 'turtle', environment: 'production', suffix: notification.event },
            notification,
            delayed: :completed, event: nil, model: nil
          ).once
          subject
        end
      end

      context 'without envelope' do
        let(:options) { { model: 'order', enveloped: false } }

        it 'shouldnt use envelope on publishing' do
          expect(Turtle).to receive(:publish!).with(
            { name: 'event_order', prefix: 'turtle', environment: 'production', suffix: notification.event },
            notification,
            delayed: nil, event: false, model: false
          ).once
          subject
        end
      end

      context 'with envelope' do
        let(:options) { { model: 'order', enveloped: true } }

        it 'should use envelope on publishing' do
          expect(Turtle).to receive(:publish!).with(
            { name: 'event_order', prefix: 'turtle', environment: 'production', suffix: notification.event },
            notification,
            delayed: nil, event: :completed, model: 'order'
          ).once
          subject
        end
      end
    end
  end
end
