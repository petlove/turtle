# frozen_string_literal: true

RSpec.describe AWS::SNS::Configurator::Publisher, type: :model do
  describe '#initialize' do
    let(:topic) { { name: 'customer', region: 'us-east-1' } }
    let(:message) { { name: 'linqueta', blog: 'linqueta.com' } }
    subject { described_class.new(topic, message) }

    it 'should have accessors' do
      expect(subject.topic).to be_a(AWS::SNS::Configurator::Topic)
      expect(subject.message).to eq(message)
    end
  end

  describe '#publish!' do
    let(:publisher) { build :publisher }
    subject { publisher.publish! }

    after { subject }

    it 'should call topic to publish' do
      expect(publisher.topic).to receive(:publish!).once
    end
  end
end
