require 'spec_helper'

RSpec.describe Turtle::EventNotificator::Action, type: :model do
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
    let(:event) { described_class.new(name) }
    subject { event.match?(before, after) }

    context 'when both params are nil' do
      let(:before) { nil }
      let(:after) { nil }
      let(:name) { 'completed' }

      it 'should unmatch' do
        is_expected.to be_falsey
      end
    end

    context 'when both params are equal' do
      let(:before) { { action: :updated } }
      let(:after) { { action: :updated } }

      context 'when the name is the same than both' do
        let(:name) { :updated }

        it 'should match' do
          is_expected.to be_truthy
        end
      end

      context 'when the name is different than both' do
        let(:name) { :created }

        it 'should unmatch' do
          is_expected.to be_falsey
        end
      end
    end

    context 'when both params are different' do
      let(:before) { { action: :created } }
      let(:after) { { action: :updated } }

      context 'when the name is the differnt than both' do
        let(:name) { :destroyed }

        it 'should unmatch' do
          is_expected.to be_falsey
        end
      end

      context 'when the name is the same than before' do
        let(:name) { :created }

        it 'should match' do
          is_expected.to be_truthy
        end
      end

      context 'when the name is the same than after' do
        let(:name) { :updated }

        it 'should match' do
          is_expected.to be_truthy
        end
      end
    end

    context 'when before are nil' do
      let(:before) { nil }

      context 'when the name is the same than after' do
        let(:after) { { action: :updated } }
        let(:name) { :updated }

        it 'should unmatch' do
          is_expected.to be_falsey
        end
      end

      context 'when the name is the different than after' do
        let(:after) { { state: :updated } }
        let(:name) { :created }

        it 'should unmatch' do
          is_expected.to be_falsey
        end
      end
    end

    context 'when after are nil' do
      let(:after) { nil }

      context 'when the name is the same than before' do
        let(:before) { { action: :updated } }
        let(:name) { :updated }

        it 'should unmatch' do
          is_expected.to be_falsey
        end
      end

      context 'when the name is the different than before' do
        let(:before) { { action: :updated } }
        let(:name) { :created }

        it 'should unmatch' do
          is_expected.to be_falsey
        end
      end
    end
  end

  describe '#build_notification' do
    let(:event) { build(:event_notificator_state) }
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
