# frozen_string_literal: true

RSpec.describe Turtle::Logger, type: :module do
  describe '.info' do
    it 'delegates to Turtle.logger' do
      expect(Turtle.logger).to receive(:info).with('the message')
      described_class.info('the message')
    end
  end

  describe '.error' do
    it 'delegates to Turtle.logger' do
      expect(Turtle.logger).to receive(:error).with('the message')
      described_class.error('the message')
    end
  end
end
