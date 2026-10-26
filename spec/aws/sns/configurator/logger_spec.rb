# frozen_string_literal: true

RSpec.describe AWS::SNS::Configurator::Logger, type: :module do
  describe '.info' do
    context 'when Turtle.logger is set' do
      it 'delegates to Turtle.logger' do
        expect(Turtle.logger).to receive(:info).with('the message')
        described_class.info('the message')
      end

      it 'ignores the env var' do
        allow(ENV).to receive(:[]).with(described_class::LOGGER_ENABLED_ENV).and_return('false')
        expect(Turtle.logger).to receive(:info).with('the message')
        described_class.info('the message')
      end
    end

    context 'when Turtle.logger is not set' do
      before { Turtle.logger = nil }

      context 'when log is disabled' do
        before { allow(ENV).to receive(:[]).with(described_class::LOGGER_ENABLED_ENV).and_return('false') }

        it 'does not print' do
          expect(described_class).not_to receive(:puts)
          described_class.info('the message')
        end
      end

      context 'when log is enabled' do
        before { allow(ENV).to receive(:[]).with(described_class::LOGGER_ENABLED_ENV).and_return(nil) }

        it 'prints to stdout' do
          expect(described_class).to receive(:puts).with('the message').once
          described_class.info('the message')
        end
      end
    end
  end

  describe '.error' do
    context 'when Turtle.logger is set' do
      it 'delegates to Turtle.logger' do
        expect(Turtle.logger).to receive(:error).with('the message')
        described_class.error('the message')
      end
    end

    context 'when Turtle.logger is not set' do
      before { Turtle.logger = nil }

      context 'when log is disabled' do
        before { allow(ENV).to receive(:[]).with(described_class::LOGGER_ENABLED_ENV).and_return('false') }

        it 'does not print' do
          expect(described_class).not_to receive(:puts)
          described_class.error('the message')
        end
      end

      context 'when log is enabled' do
        before { allow(ENV).to receive(:[]).with(described_class::LOGGER_ENABLED_ENV).and_return(nil) }

        it 'prints to stdout' do
          expect(described_class).to receive(:puts).with('the message').once
          described_class.error('the message')
        end
      end
    end
  end
end
