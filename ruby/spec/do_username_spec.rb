RSpec.describe DOUsername do
  describe '#generate' do
    subject { described_class }

    # Please update this spec if module constants are updated
    # see more at: https://github.com/MattIPv4/do_username/pull/8
    it 'responds with different usernames based on srand' do
      %w[
        HappyElectricBlueBoat DriftingAquaShark MassiveTurquoiseWhale
      ].each_with_index do |username, i|
        srand i

        expect(subject.generate).to eq(username)
      end
    end

    it 'responds with string' do
      expect(subject.generate).to be_a String
    end

    it 'responds with CamelCase string' do
      expect(subject.generate.scan(/[A-Z]/).size).to be >= 3
    end

    it 'responds with whitespace-free string' do
      expect(subject.generate.scan(/\s/).size).to be 0
    end

    context 'with noun part' do
      before { stub_const('DOUsername::SEA_LIST', ['walrus']) }

      it 'ends with a sea object or a creature' do
        expect(subject.generate).to end_with('Walrus')
      end
    end

    context 'with descriptor part' do
      before do
        stub_const('DOUsername::DESCRIPTORS', ['cute'])
        stub_const('DOUsername::SEA_CREATURES', [])
      end

      it 'starts with a descriptor' do
        expect(subject.generate).to start_with('Cute')
      end
    end

    context 'with color part' do
      before { stub_const('DOUsername::COLORS', ['blue']) }

      it 'contains a color in generated username' do
        expect(subject.generate).to include('Blue')
      end
    end

    context 'with max_size argument' do
      before do
        stub_const('DOUsername::DESCRIPTORS', ['cute'])
        stub_const('DOUsername::SEA_LIST', ['walrus'])
        stub_const('DOUsername::COLORS', ['red'])
        stub_const('DOUsername::SEA_CREATURES', [])
      end

      it 'responds with username shorter than or equal to given size' do
        expect(subject.generate(15).size).to be <= 15
      end

      it 'responds with full combination when appropriate' do
        expect(subject.generate(100)).to eq('CuteRedWalrus')
      end

      it 'responds with descriptor + noun when appropriate' do
        expect(subject.generate(12)).to eq('CuteWalrus')
      end

      it 'responds with color + noun when appropriate' do
        expect(subject.generate(9)).to eq('RedWalrus')
      end

      it 'responds with part of the noun when appropriate' do
        expect(subject.generate(5)).to eq('Walru')
      end

      context 'when is invalid' do
        it 'raises ArgumentError negative values' do
          expect do
            subject.generate(-99)
          end.to raise_error(ArgumentError, 'The max_size argument must be an integer number greater than zero.')
        end

        it 'raises ArgumentError for zero' do
          expect do
            subject.generate(0)
          end.to raise_error(ArgumentError, 'The max_size argument must be an integer number greater than zero.')
        end

        it 'raises ArgumentError for non-integer values' do
          expect do
            subject.generate('abc')
          end.to raise_error(ArgumentError, 'The max_size argument must be an integer number greater than zero.')
        end
      end
    end
  end

  describe '#random_noun' do
    subject { described_class }

    before do
      stub_const('DOUsername::SEA_LIST', ['walrus'])
    end

    it 'returns an item from the list of creatures and objects' do
      expect(subject.send(:random_noun)).to eq('walrus')
    end
  end

  describe '#random_descriptor' do
    subject { described_class }

    context 'when the noun is a sea object' do
      # This doesn't completely test that this can't return a value from
      # CREATURE_DESCRIPTORS, just that it returns a value from DESCRIPTORS
      before do
        stub_const('DOUsername::SEA_CREATURES', [])
        stub_const('DOUsername::DESCRIPTORS', ['cute'])
      end

      it 'returns an item from the list of descriptors' do
        expect(subject.send(:random_descriptor, 'walrus')).to eq('cute')
      end
    end

    context 'when the noun is a sea creature' do
      before do
        stub_const('DOUsername::SEA_CREATURES', ['walrus'])
      end

      context 'with creature descriptors present' do
        before do
          stub_const('DOUsername::DESCRIPTORS', [])
          stub_const('DOUsername::CREATURE_DESCRIPTORS', ['huge'])
        end

        it 'returns an item from the list of creature descriptors' do
          expect(subject.send(:random_descriptor, 'walrus')).to eq('huge')
        end
      end

      context 'with generic descriptors present' do
        before do
          stub_const('DOUsername::DESCRIPTORS', ['cute'])
          stub_const('DOUsername::CREATURE_DESCRIPTORS', [])
        end

        it 'returns an item from the list of descriptors' do
          expect(subject.send(:random_descriptor, 'walrus')).to eq('cute')
        end
      end
    end
  end

  describe '#random_color' do
    subject { described_class }

    before do
      stub_const('DOUsername::COLORS', ['red'])
    end

    it 'returns an item from the list of colors' do
      expect(subject.send(:random_color)).to eq('red')
    end
  end

  describe '#format' do
    subject { described_class }

    it 'sets the first character to be uppercase' do
      expect(subject.send(:format, 'test')).to eq('Test')
    end

    context 'with a string with existing uppercase characters' do
      it 'does not force existing characters to lowercase' do
        expect(subject.send(:format, 'testTesting')).to eq('TestTesting')
      end
    end
  end

  describe '#combine_username' do
    subject { described_class }

    context 'when max_size allows for the full combination' do
      it 'responds with full combination (descriptor + color + noun)' do
        expect(subject.send(:combine_username, 100, 'Swimming', 'Red', 'Walrus'))
          .to eq('SwimmingRedWalrus')
      end
    end

    context 'when max_size allows for the descriptor and noun' do
      it 'responds with the descriptor + noun combination' do
        expect(subject.send(:combine_username, 14, 'Swimming', 'Red', 'Walrus'))
          .to eq('SwimmingWalrus')
      end
    end

    context 'when max_size allows for the color and noun' do
      it 'responds with the colors + noun combination' do
        expect(subject.send(:combine_username, 9, 'Swimming', 'Red', 'Walrus'))
          .to eq('RedWalrus')
      end
    end

    context 'when max_size allows for the noun' do
      it 'responds with just the noun' do
        expect(subject.send(:combine_username, 6, 'Swimming', 'Red', 'Walrus'))
          .to eq('Walrus')
      end
    end

    context 'when max_size is shorter than the noun' do
      it 'responds with the noun trimmed to the max size' do
        expect(subject.send(:combine_username, 4, 'Swimming', 'Red', 'Walrus'))
          .to eq('Walr')
      end
    end
  end
end
