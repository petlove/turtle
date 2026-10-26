# frozen_string_literal: true

RSpec.describe Turtle, type: :module do
  it 'has a version number' do
    expect(Turtle::VERSION).not_to be nil
  end

  describe '#shoryuken_queues_priorities' do
    context 'call through' do
      subject { described_class.shoryuken_queues_priorities({}) }

      before { allow(described_class::Group).to receive(:to_h).and_return({}) }
      after { subject }

      it 'should call through Queue' do
        expect(described_class::Queue).to receive(:shoryuken_priorities).once.and_return([])
      end
    end

    context 'with grouped queues' do
      subject { described_class.shoryuken_queues_priorities }

      before { stub_const('AWS::SQS::Configurator::Reader::MAIN_FILE', './spec/fixtures/configs/with_shoryuken_groups.yml') }

      it 'returns only queues not assigned to a group' do
        is_expected.to eq([['app_name_production_regular_a', 5], ['app_name_production_regular_b', 3]])
      end

      it 'excludes grouped queues by name regardless of priority' do
        allow(described_class::Queue).to receive(:shoryuken_priorities).and_return(
          [['app_name_production_regular_a', 5], ['app_name_production_batch_solo', 99]]
        )
        is_expected.to eq([['app_name_production_regular_a', 5]])
      end
    end
  end

  describe '#shoryuken_groups' do
    subject { described_class.shoryuken_groups }

    before { stub_const('AWS::SQS::Configurator::Reader::MAIN_FILE', './spec/fixtures/configs/with_shoryuken_groups.yml') }

    it 'returns groups as JSON string ready for shoryuken.yml' do
      parsed = JSON.parse(subject)
      expect(parsed['batch_solo']).to eq('concurrency' => 1, 'queues' => [['app_name_production_batch_solo', 1]])
    end

    it 'produces no overlap with shoryuken_queues_priorities' do
      queue_names = described_class.shoryuken_queues_priorities.map(&:first)
      group_queue_names = JSON.parse(subject).values.flat_map { |g| g['queues'].map(&:first) }
      expect(queue_names & group_queue_names).to be_empty
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
      is_expected.to eq([300, 900, 1800, 3600, 10_800, 43_200])
    end
  end

  describe '.logger' do
    it 'returns a Logger instance by default when Rails is absent' do
      Turtle.logger = nil
      expect(Turtle.logger).to be_a(::Logger)
    end

    it 'returns the assigned logger' do
      custom = ::Logger.new(IO::NULL)
      Turtle.logger = custom
      expect(Turtle.logger).to eq(custom)
    end

    it 'is set? after assignment' do
      Turtle.logger = ::Logger.new(IO::NULL)
      expect(Turtle.logger_set?).to be true
    end

    it 'is not set? after reset to nil' do
      Turtle.logger = ::Logger.new(IO::NULL)
      Turtle.logger = nil
      expect(Turtle.logger_set?).to be false
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
