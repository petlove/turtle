# frozen_string_literal: true

RSpec.describe AWS::SNS::Configurator::Client, type: :model do
  describe '#initialize' do
    subject { described_class.new(region) }

    context 'without region' do
      let(:region) { nil }

      it 'should raise missing region error' do
        expect { subject }.to raise_error(Aws::Errors::MissingRegionError)
      end
    end

    context 'with region' do
      let(:region) { 'us-east-1' }

      it 'should have an aws client', :vcr do
        expect(subject.aws).to be_a(Aws::SNS::Client)
      end
    end
  end
end
