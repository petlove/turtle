# frozen_string_literal: true

RSpec.describe AWS::SNS::Configurator do
  it 'has a version number' do
    expect(AWS::SNS::Configurator::VERSION).not_to be nil
  end

  describe '#create!' do
    subject { described_class.create! }

    after { subject }

    context 'default' do
      it 'should use the class Creator to create the topics' do
        expect_any_instance_of(described_class::Creator).to receive(:initialize).once
        expect_any_instance_of(described_class::Creator).to receive(:create!).once
      end
    end
  end

  describe '#subscribe!' do
    subject { described_class.subscribe!({ name: 'customer', region: 'us-east-1' }, protocol, endpoint, raw: raw) }

    after { subject }

    context 'protocol sqs' do
      let(:protocol) { 'sqs' }
      let(:endpoint) { 'arn' }
      let(:raw) { true }

      it 'should use subscribe through the topic' do
        expect_any_instance_of(described_class::Subscriber).to receive(:subscribe!).once
      end
    end
  end

  describe '#topics!' do
    subject { described_class.topics! }

    after { subject }

    it 'should use reader to get topics' do
      expect_any_instance_of(described_class::Reader).to receive(:read!)
    end
  end

  describe '#publish!' do
    subject { described_class.publish!({ name: 'customer', region: 'us-east-1' }, name: 'linqueta', blog: 'linqueta.com') }

    after { subject }

    it 'should use publish through the topic' do
      expect_any_instance_of(described_class::Publisher).to receive(:publish!).once
    end
  end
end
