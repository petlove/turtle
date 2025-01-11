# frozen_string_literal: true

RSpec.describe AWS::SNS::Configurator::Creator, type: :model do
  describe '#initialize' do
    before { stub_const('AWS::SNS::Configurator::Reader::MAIN_FILE', './spec/fixtures/configs/aws-sns-shoryuken.yml') }

    it 'should have created and found empty' do
      expect(subject.created).to be_empty
      expect(subject.found).to be_empty
    end

    it 'should get topics' do
      expect(subject.topics.all? { |t| t.is_a?(AWS::SNS::Configurator::Topic) }).to be_truthy
    end
  end

  describe '#create!' do
    let(:instance) { described_class.new }
    subject { instance.create! }

    before { stub_const('AWS::SNS::Configurator::Reader::MAIN_FILE', './spec/fixtures/configs/aws-sns-shoryuken.yml') }

    after { subject }

    context 'default' do
      it 'should create 1 topic', :vcr do
        expect(subject.created.length).to eq(1)
      end
    end
  end
end
