# frozen_string_literal: true

RSpec.describe AWS::SNS::Configurator::Package, type: :model do
  describe '#initialize' do
    subject { described_class.new(content) }

    context 'with nil content' do
      let(:content) { nil }

      it 'should have content with empty topics array' do
        expect(subject.content).to eq(topics: [])
      end

      it 'should have empty topic options' do
        expect(subject.topics_options).to eq([])
      end

      it 'should have empty general default options' do
        expect(subject.general_default_options).to eq({})
      end

      it 'should have empty topic default options' do
        expect(subject.topic_default_options).to eq({})
      end
    end

    context 'with empty topics' do
      let(:content) { { topics: [] } }

      it 'should have content with empty topics array' do
        expect(subject.content).to eq(topics: [])
      end

      it 'should have empty topic options' do
        expect(subject.topics_options).to eq([])
      end

      it 'should have empty general default options' do
        expect(subject.general_default_options).to eq({})
      end

      it 'should have empty topic default options' do
        expect(subject.topic_default_options).to eq({})
      end
    end

    context 'with default options and topics' do
      let(:content) do
        {
          default: {
            general: {
              region: 'us-east-1',
              prefix: 'prices',
              suffix: 'warning',
              environment: 'staging',
              metadata: {
                priority: 1
              }
            },
            topic: {
              region: 'us-east-2',
              prefix: 'products',
              suffix: 'failures',
              environment: 'production',
              metadata: {
                priority: 2
              }
            }
          },
          topics: [
            {
              name: 'prices_update',
              region: 'us-east-2'
            },
            {
              name: 'prices_adjuster',
              suffix: 'alert',
              region: 'sa-east-1'
            }
          ]
        }
      end

      it 'should have content' do
        expect(subject.content).to eq(
          default: {
            general: {
              region: 'us-east-1',
              prefix: 'prices',
              suffix: 'warning',
              environment: 'staging',
              metadata: {
                priority: 1
              }
            },
            topic: {
              region: 'us-east-2',
              prefix: 'products',
              suffix: 'failures',
              environment: 'production',
              metadata: {
                priority: 2
              }
            }
          },
          topics: [
            {
              name: 'prices_update',
              region: 'us-east-2'
            },
            {
              name: 'prices_adjuster',
              suffix: 'alert',
              region: 'sa-east-1'
            }
          ]
        )
      end

      it 'should have topics options' do
        expect(subject.topics_options).to eq(
          [
            {
              name: 'prices_update',
              region: 'us-east-2'
            },
            {
              name: 'prices_adjuster',
              suffix: 'alert',
              region: 'sa-east-1'
            }
          ]
        )
      end

      it 'should have general default options' do
        expect(subject.general_default_options).to eq(
          environment: 'staging',
          prefix: 'prices',
          region: 'us-east-1',
          suffix: 'warning',
          metadata: {
            priority: 1
          }
        )
      end

      it 'should have topic default options' do
        expect(subject.topic_default_options).to eq(
          environment: 'production',
          prefix: 'products',
          region: 'us-east-2',
          suffix: 'failures',
          metadata: {
            priority: 2
          }
        )
      end
    end
  end

  describe '#unpack!' do
    subject { described_class.new(content).unpack! }

    context 'with empty topics options' do
      let(:content) { nil }

      it 'should return emtpy array' do
        is_expected.to eq([])
      end
    end

    context 'with topics options' do
      let(:content) do
        {
          topics: [
            {
              name: 'prices_update',
              region: 'us-east-2'
            },
            {
              name: 'prices_adjuster',
              suffix: 'alert',
              region: 'sa-east-1'
            }
          ]
        }
      end

      it 'should return two topics' do
        expect(subject.length).to eq(2)
        expect(subject.all? { |s| s.is_a?(AWS::SNS::Configurator::Topic) }).to be_truthy
      end

      it 'should have name and region' do
        expect(subject.first.name).to eq('prices_update')
        expect(subject.first.region).to eq('us-east-2')
      end

      it 'should have name, suffix and region' do
        expect(subject.first(2).last.name).to eq('prices_adjuster')
        expect(subject.first(2).last.suffix).to eq('alert')
        expect(subject.first(2).last.region).to eq('sa-east-1')
      end
    end

    context 'with general and topics options' do
      let(:content) do
        {
          default: {
            general: {
              region: 'us-east-1',
              prefix: 'prices',
              suffix: 'warning',
              environment: 'staging',
              metadata: {
                priority: 1
              }
            }
          },
          topics: [
            {
              name: 'prices_update'
            }
          ]
        }
      end

      it 'should apply general default options' do
        expect(subject.first.name).to eq('prices_update')
        expect(subject.first.region).to eq('us-east-1')
        expect(subject.first.prefix).to eq('prices')
        expect(subject.first.suffix).to eq('warning')
        expect(subject.first.environment).to eq('staging')
        expect(subject.first.metadata).to eq(priority: 1)
      end
    end

    context 'with general, topic and topics options' do
      let(:content) do
        {
          default: {
            general: {
              region: 'us-east-1',
              prefix: 'prices',
              suffix: 'warning',
              environment: 'staging',
              metadata: {
                priority: 1
              }
            },
            topic: {
              region: 'us-east-2',
              prefix: 'products',
              suffix: 'failures',
              environment: 'production',
              metadata: {
                priority: 2
              }
            }
          },
          topics: [
            {
              name: 'prices_update'
            }
          ]
        }
      end

      it 'should apply general default options' do
        expect(subject.first.name).to eq('prices_update')
        expect(subject.first.region).to eq('us-east-2')
        expect(subject.first.prefix).to eq('products')
        expect(subject.first.suffix).to eq('failures')
        expect(subject.first.environment).to eq('production')
        expect(subject.first.metadata).to eq(priority: 2)
      end
    end

    context 'with general, topic and full topics options' do
      let(:content) do
        {
          default: {
            general: {
              region: 'us-east-1',
              prefix: 'prices',
              suffix: 'warning',
              environment: 'staging',
              metadata: {
                priority: 1
              }
            },
            topic: {
              region: 'us-east-2',
              prefix: 'products',
              suffix: 'failures',
              environment: 'production',
              metadata: {
                priority: 2
              }
            }
          },
          topics: [
            {
              name: 'prices_update',
              region: 'sa-east-1',
              prefix: 'topics',
              suffix: 'errors',
              environment: 'development',
              metadata: {
                priority: 3
              }
            }
          ]
        }
      end

      it 'should apply general default options' do
        expect(subject.first.name).to eq('prices_update')
        expect(subject.first.region).to eq('sa-east-1')
        expect(subject.first.prefix).to eq('topics')
        expect(subject.first.suffix).to eq('errors')
        expect(subject.first.environment).to eq('development')
        expect(subject.first.metadata).to eq(priority: 3)
      end
    end
  end
end
