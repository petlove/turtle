RSpec.describe Turtle, type: :module do
  it 'has a version number' do
    expect(Turtle::VERSION).not_to be nil
  end

  describe '#shoryuken_queues_priorities' do
    subject { described_class.shoryuken_queues_priorities({}) }

    after { subject }

    it 'should call through Queue' do
      expect(described_class::Queue).to receive(:shoryuken_priorities).once
    end
  end

  describe '#delayed_job_queue_attributes' do
    subject { described_class.delayed_job_queue_attributes }
    before { stub_const('AWS::SNS::Configurator::Reader::MAIN_FILE', './spec/fixtures/configs/topics.yml') }
    before { stub_const('AWS::SQS::Configurator::Reader::MAIN_FILE', './spec/fixtures/configs/queues.yml') }

    it 'should return priority two queues' do
      is_expected.to eq(
        topic_system_name_production_address_alert: { priority: 1 },
        topic_system_name_production_customer_topic: { priority: 1 },
        queue_system_name_production_product_adjuster_alert: { priority: 2 },
        queue_system_name_production_product_updater_queue: { priority: 1 }
      )
    end
  end
end
