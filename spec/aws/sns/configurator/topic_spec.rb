# frozen_string_literal: true

RSpec.describe AWS::SNS::Configurator::Topic, type: :model do
  describe '#initialize' do
    before { allow_any_instance_of(described_class).to receive(:account_id).and_return('123456789') }
    subject { described_class.new(options) }

    context 'without name' do
      let(:options) { {} }

      it 'should raise RequiredFieldError' do
        expect { subject }.to raise_error(described_class::RequiredFieldError, 'The field name is required')
      end
    end

    context 'without region' do
      let(:options) { { name: 'update_price' } }

      before { ENV['AWS_REGION'] = nil }

      it 'should raise RequiredFieldError' do
        expect { subject }.to raise_error(described_class::RequiredFieldError, 'The field region is required')
      end
    end

    context 'with just the name' do
      let(:options) { 'update_price' }

      context 'without AWS_REGION environment' do
        it 'should raise RequiredFieldError' do
          expect { subject }.to raise_error(described_class::RequiredFieldError, 'The field region is required')
        end
      end

      context 'with AWS_REGION environment' do
        before { ENV['AWS_REGION'] = 'us-east-1' }

        it 'should have accessors' do
          expect(subject.name).to eq('update_price')
          expect(subject.region).to eq('us-east-1')
          expect(subject.prefix).to be_nil
          expect(subject.suffix).to be_nil
          expect(subject.environment).to be_nil
          expect(subject.metadata).to eq({})
          expect(subject.name_formatted).to eq('update_price')
          expect(subject.arn).to eq('arn:aws:sns:us-east-1:123456789:update_price')
        end
      end
    end

    context 'without all options' do
      let(:options) do
        {
          name: 'update_price',
          region: 'us-east-1',
          prefix: 'prices',
          suffix: 'warning',
          environment: 'production',
          metadata: {
            type: 'strict'
          }
        }
      end

      it 'should have accessors' do
        expect(subject.name).to eq('update_price')
        expect(subject.region).to eq('us-east-1')
        expect(subject.prefix).to eq('prices')
        expect(subject.suffix).to eq('warning')
        expect(subject.environment).to eq('production')
        expect(subject.metadata[:type]).to eq('strict')
        expect(subject.name_formatted).to eq('prices_production_update_price_warning')
        expect(subject.arn).to eq('arn:aws:sns:us-east-1:123456789:prices_production_update_price_warning')
      end
    end

    context '#topic_params' do
      context 'fifo topic' do
        let(:options) do
          {
            name: 'update_price',
            region: 'us-east-1',
            prefix: 'prices',
            suffix: 'warning',
            environment: 'production',
            metadata: {
              type: 'strict'
            }
          }
        end

        it 'should create topic with fifo attributes' do
          expect(subject.name_formatted).to eq('prices_production_update_price_warning')
          expect(subject.topic_params).to eq({ name: 'prices_production_update_price_warning' })
        end
      end

      context 'fifo topic' do
        let(:options) do
          {
            name: 'update_price',
            region: 'us-east-1',
            prefix: 'prices',
            suffix: 'warning.fifo',
            environment: 'production',
            metadata: {
              type: 'strict'
            }
          }
        end

        it 'should create topic with fifo attributes' do
          expect(subject.name_formatted).to eq('prices_production_update_price_warning.fifo')
          expect(subject.topic_params).to eq(
            { name: 'prices_production_update_price_warning.fifo', attributes: { 'FifoTopic' => 'true' } }
          )
        end
      end
    end
  end

  describe '#create!' do
    let(:topic) { build :topic }
    let(:client) { build :sns_client }
    subject { topic.create!(client) }

    it 'should create the topic', :vcr do
      expect(subject.topic_arn).to eq(topic.arn)
    end
  end

  describe '#subscribe!' do
    let(:topic) { build :topic }
    let(:client) { build :sns_client }
    let(:protocol) { 'sqs' }
    let(:endpoint) { "arn:aws:sqs:us-east-1:#{ENV['AWS_ACCOUNT_ID']}:linqueta_production_queue_failures" }
    let(:raw) { true }

    subject { topic.subscribe!(protocol, endpoint, raw: raw) }

    after { subject }

    it 'should create subscription in the topic', :vcr do
      is_expected.to be_truthy
    end

    it 'should add raw attribute', :vcr do
      expect(topic).to receive(:raw_attribute).once.and_call_original
    end

    it 'should call to add attributes', :vcr do
      expect(topic).to receive(:subscription_attributes!).once.and_call_original
    end
  end

  describe '#publish!' do
    let(:topic) { build :topic }
    let(:aws_client) { double('AwsClient') }
    subject { topic.publish!(name: 'linqueta', blog: 'linqueta.com') }

    before do
      allow(topic).to receive_message_chain(:default_client, :aws).and_return(aws_client)
      allow(aws_client).to receive(:publish)
    end

    context 'when payload is a hash' do
      let(:message) { { nome: 'linqueta', blog: 'linqueta.com' } }

      it 'should publish in the topic with message as json' do
        expect(aws_client).to receive(:publish).with(
          topic_arn: topic.arn,
          message: message.to_json
        )
        topic.publish!(message)
      end
    end

    context 'when message is a json string' do
      let(:json_message) { '{"nome":"linqueta", "blog":"linqueta.com"}' }

      it 'should publish in the topic with message as json' do
        expect(aws_client).to receive(:publish).with(
          topic_arn: topic.arn,
          message: json_message
        )
        topic.publish!(json_message)
      end
    end
  end
end
