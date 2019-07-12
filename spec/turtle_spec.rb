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

  describe '#enqueue!' do
    subject { described_class.enqueue!(Object, { hello: :world }, seconds: 10, delayed: true) }

    after { subject }

    it 'should call through Queue' do
      expect(described_class::Queue).to receive(:enqueue!).once
    end
  end

  describe '#publish!' do
    subject { described_class.publish!(Object, { hello: :world }, delayed: true) }

    after { subject }

    it 'should call through Topic' do
      expect(described_class::Topic).to receive(:publish!).once
    end
  end

  describe '#retry_intervals' do
    subject { described_class.retry_intervals }

    it 'should return the intervals' do
      is_expected.to eq([5.minutes, 15.minutes, 30.minutes, 1.hour, 3.hours, 12.hours])
    end
  end

  describe '#name_for' do
    subject { described_class.name_for(type, 'linqueta', region: 'us-east-1', prefix: 'beagle', environment: 'dev') }

    context 'with queue' do
      let(:type) { :queue }

      it 'should return queue name formatted' do
        is_expected.to eq('beagle_dev_linqueta')
      end
    end

    context 'with topic' do
      let(:type) { :topic }

      it 'should return topic name formatted' do
        is_expected.to eq('beagle_dev_linqueta')
      end
    end
  end
end
