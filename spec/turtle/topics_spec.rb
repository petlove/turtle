# frozen_string_literal: true

RSpec.describe Turtle::Topic, type: :model do
  describe '#delayed_job_queue_attributes' do
    subject { described_class.delayed_job_queue_attributes }
    before { stub_const('AWS::SNS::Configurator::Reader::MAIN_FILE', './spec/fixtures/configs/topics.yml') }

    it 'should return priority two queues' do
      is_expected.to eq(
        topic_system_name_production_address_alert: { priority: 1 },
        topic_system_name_production_customer_topic: { priority: 1 }
      )
    end
  end

  describe '#publish!' do
    let(:data) { { hello: :data } }
    before { ENV['AWS_ACCOUNT_ID'] = '000000000000' }
    subject { described_class.publish!(topic, data, options) }
    before do
      allow(AWS::SNS::Configurator).to receive(:delay).and_return(Object)
    end

    context 'with topic name' do
      let(:options) { {} }
      let(:topic) { 'order_event_created' }

      context 'without region env' do
        before { ENV['AWS_REGION'] = nil }

        it 'should raise error' do
          expect { subject }.to raise_error(AWS::SNS::Configurator::Topic::RequiredFieldError, 'The field region is required')
        end
      end

      context 'with region env' do
        before { ENV['AWS_REGION'] = 'us-east-1' }
        after { subject }

        it 'should publish through AWS::SNS::Configurator::Topic' do
          expect_any_instance_of(AWS::SNS::Configurator::Topic).to receive(:publish!).with(data).once
        end
      end
    end

    context 'with topic hash' do
      let(:topic) { { name: 'order_event_created', region: 'us-east-1' } }

      after { subject }

      context 'with delay' do
        let(:options) { { delay: true } }

        it 'should use delay with correct queue and publish through AWS::SNS::Configurator::Topic' do
          expect(AWS::SNS::Configurator).to receive(:delay).with(queue: 'topic_order_event_created').once.and_return(AWS::SNS::Configurator)
          expect_any_instance_of(AWS::SNS::Configurator::Topic).to receive(:publish!).with(data).once
        end
      end

      context 'with event' do
        let(:envelope) { { event: 'order_created', model: nil, data: data } }
        let(:options) { { event: 'order_created' } }

        it 'should envelope the payload and publish through AWS::SNS::Configurator::Topic' do
          expect_any_instance_of(AWS::SNS::Configurator::Topic).to receive(:publish!).with(envelope).once
        end
      end

      context 'with model' do
        let(:envelope) { { model: 'spree_order', event: nil, data: data } }
        let(:options) { { model: 'spree_order' } }

        it 'should envelope the payload and publish through AWS::SNS::Configurator::Topic' do
          expect_any_instance_of(AWS::SNS::Configurator::Topic).to receive(:publish!).with(envelope).once
        end
      end
    end
  end
end
