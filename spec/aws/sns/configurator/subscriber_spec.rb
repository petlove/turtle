# frozen_string_literal: true

RSpec.describe AWS::SNS::Configurator::Subscriber, type: :model do
  describe '#initialize' do
    let(:topic) { { name: 'customer', region: 'us-east-1' } }
    subject { described_class.new(topic, protocol, endpoint, options) }

    context 'sqs protocol' do
      let(:protocol) { 'sqs' }
      let(:endpoint) { 'arn' }
      let(:options) { { raw: true } }

      it 'should have accessors' do
        expect(subject.topic).to be_a(AWS::SNS::Configurator::Topic)
        expect(subject.protocol).to eq('sqs')
        expect(subject.endpoint).to eq('arn')
        expect(subject.options).to eq(raw: true)
      end
    end
  end

  describe '#subscribe!' do
    subject { subscriber.subscribe! }

    after { subject }

    context 'sqs protocol' do
      let(:subscriber) { build :subscriber_sqs }

      it 'should call topic to subscribe' do
        expect(subscriber.topic).to receive(:subscribe!).once
      end
    end
  end
end
