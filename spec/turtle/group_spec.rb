# frozen_string_literal: true

RSpec.describe Turtle::Group, type: :model do
  after { described_class.instance_variable_set(:@to_h, nil) }

  describe '.to_h' do
    subject { described_class.to_h }

    context 'without groups section' do
      before { stub_const('AWS::SQS::Configurator::Reader::MAIN_FILE', './spec/fixtures/configs/queues.yml') }

      it { is_expected.to eq({}) }
    end

    context 'with groups section' do
      before { stub_const('AWS::SQS::Configurator::Reader::MAIN_FILE', './spec/fixtures/configs/with_shoryuken_groups.yml') }

      it 'returns groups with resolved queues and attributes' do
        is_expected.to eq(
          'batch_solo' => { concurrency: 1, queues: [['app_name_production_batch_solo', 1]] },
          'batch_multi' => {
            concurrency: 3,
            delay: 30,
            polling_strategy: 'WeightedRoundRobin',
            queues: [['app_name_production_batch_multi_a', 2], ['app_name_production_batch_multi_b', 2]]
          }
        )
      end
    end

    context 'with groups in DIR_FILES' do
      before do
        stub_const('AWS::SQS::Configurator::Reader::DIR_FILES', './spec/fixtures/configs/with_shoryuken_groups.yml')
        stub_const('AWS::SQS::Configurator::Reader::MAIN_FILE', './spec/fixtures/configs/nonexistent.yml')
      end

      it 'returns groups resolved from directory config files' do
        is_expected.to eq(
          'batch_solo' => { concurrency: 1, queues: [['app_name_production_batch_solo', 1]] },
          'batch_multi' => {
            concurrency: 3,
            delay: 30,
            polling_strategy: 'WeightedRoundRobin',
            queues: [['app_name_production_batch_multi_a', 2], ['app_name_production_batch_multi_b', 2]]
          }
        )
      end
    end

    context 'with all queues grouped' do
      before { stub_const('AWS::SQS::Configurator::Reader::MAIN_FILE', './spec/fixtures/configs/with_all_queues_grouped.yml') }

      it 'returns all groups with their attributes and queues' do
        is_expected.to eq(
          'solo_group' => { concurrency: 1, queues: [['app_name_production_grouped_solo', 1]] },
          'multi_group' => { concurrency: 2, queues: [['app_name_production_grouped_multi_a', 2], ['app_name_production_grouped_multi_b', 2]] }
        )
      end
    end
  end

  describe '.to_h logging' do
    before { stub_const('AWS::SQS::Configurator::Reader::MAIN_FILE', './spec/fixtures/configs/with_shoryuken_groups.yml') }

    it 'logs each group with name, concurrency and queues' do
      expect(Turtle::Logger).to receive(:info).with('Group added: batch_solo concurrency: 1 queues: app_name_production_batch_solo')
      expect(Turtle::Logger).to receive(:info).with('Group added: batch_multi concurrency: 3 queues: app_name_production_batch_multi_a, app_name_production_batch_multi_b')
      described_class.to_h
    end
  end

  describe '.to_json' do
    subject { described_class.to_json }

    before { stub_const('AWS::SQS::Configurator::Reader::MAIN_FILE', './spec/fixtures/configs/with_shoryuken_groups.yml') }

    it 'returns groups as a valid JSON string' do
      parsed = JSON.parse(subject)
      expect(parsed['batch_solo']).to eq('concurrency' => 1, 'queues' => [['app_name_production_batch_solo', 1]])
    end
  end
end
