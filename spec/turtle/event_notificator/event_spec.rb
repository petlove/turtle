require 'spec_helper'

RSpec.describe Turtle::EventNotificator::Event, type: :model do
  describe '#initialize' do
    subject { described_class.new(name) }

    context 'with name' do
      let(:name) { :completed }

      it 'should have a name' do
        expect(subject.name).to eq(name)
      end
    end

    context 'without name' do
      let(:name) { nil }

      it 'should be nil the name' do
        expect(subject.name).to be_nil
      end
    end
  end

  describe '#match?' do
    subject { build(:event_notificator_event).match?(nil, nil) }

    it 'should raise an error' do
      expect { subject }.to raise_error(NotImplementedError, 'You should implement the method match?')
    end
  end

  describe '#build_notification' do
    let(:event) { build(:event_notificator_event) }
    subject { event.build_notification(nil, nil) }

    context 'when have a match' do
      before { allow(event).to receive(:match?).and_return(true) }

      it 'should build an Notification' do
        is_expected.to be_a(Turtle::EventNotificator::Notification)
        expect(subject.event).to eq(event.name)
      end
    end

    context 'when havent a match' do
      before { allow(event).to receive(:match?).and_return(false) }

      it 'should be nil' do
        is_expected.to be_nil
      end
    end
  end
end
