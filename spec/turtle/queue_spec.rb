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

  describe '#enqueue!' do
    let(:data) { { hello: :data } }
    subject { described_class.enqueue!(Object, data, options) }
    before do
      allow(Object).to receive(:shoryuken_options_hash).and_return('queue' => 'object_worker')
      allow(Object).to receive(:delay).and_return(Object)
    end

    after { subject }

    context 'with seconds' do
      let(:seconds) { 900 }
      let(:options) { { seconds: seconds } }

      it 'should perforn in 900 seconds' do
        expect(Object).to receive(:perform_in).with(seconds, data).once
      end
    end

    context 'with delay' do
      let(:options) { { delay: true } }

      it 'should use delay with correct queue and perform async' do
        expect(Object).to receive(:delay).with(queue: 'queue_object_worker').once.and_return(Object)
        expect(Object).to receive(:perform_async).with(data).once
      end
    end

    context 'with event' do
      let(:envelope) { { event: 'order_created', model: nil, data: data } }
      let(:options) { { event: 'order_created' } }

      it 'should envelope the payload and perform async' do
        expect(Object).to receive(:perform_async).with(envelope).once
      end
    end

    context 'with model' do
      let(:envelope) { { model: 'spree_order', event: nil, data: data } }
      let(:options) { { model: 'spree_order' } }

      it 'should envelope the payload and perform async' do
        expect(Object).to receive(:perform_async).with(envelope).once
      end
    end
  end
end
