RSpec.describe Turtle::Queue, type: :model do
  describe '#shoryuken_queues_priorities' do
    subject { described_class.shoryuken_priorities(options) }
    before { stub_const('AWS::SQS::Configurator::Reader::MAIN_FILE', './spec/fixtures/configs/queues.yml') }

    context 'with nil option' do
      let(:options) { nil }

      it 'should return all queues' do
        is_expected.to eq([
                            ['system_name_production_product_updater_queue', 1],
                            ['system_name_production_product_adjuster_alert', 2]
                          ])
      end
    end

    context 'with option' do
      let(:options) { { priority: 2 } }

      it 'should return priority two queues' do
        is_expected.to eq([
                            ['system_name_production_product_adjuster_alert', 2]
                          ])
      end
    end
  end

  describe '#delayed_job_queue_attributes' do
    subject { described_class.delayed_job_queue_attributes }
    before { stub_const('AWS::SQS::Configurator::Reader::MAIN_FILE', './spec/fixtures/configs/queues.yml') }

    it 'should return priority two queues' do
      is_expected.to eq(
        queue_system_name_production_product_adjuster_alert: { priority: 2 },
        queue_system_name_production_product_updater_queue: { priority: 1 }
      )
    end
  end
end
