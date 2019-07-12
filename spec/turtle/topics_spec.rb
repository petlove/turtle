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
end
