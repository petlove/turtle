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
end
