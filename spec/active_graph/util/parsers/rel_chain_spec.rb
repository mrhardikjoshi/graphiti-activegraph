require 'parslet/rig/rspec'

describe Graphiti::ActiveGraph::Util::Parsers::RelChain do
  subject { described_class.new }
  context "when simple string - knows" do
    it { is_expected.to parse('knows') }
  end

  context "when not parsable string - knows***" do
    it { is_expected.not_to parse('knows***') }
  end

  context "when knows.location" do
    it { is_expected.to parse('knows.location') }
  end

  context "when knows*.location" do
    it { is_expected.to parse('knows*.location') }
  end

  context "when knows*...location" do
    it { is_expected.to parse('knows*...location') }
  end

  context "when knows*2...location" do
    it { is_expected.to parse('knows*2...location') }
  end

  context "when knows*..3.location" do
    it { is_expected.to parse('knows*..3.location') }
  end

  context "when knows*2..3.location" do
    it { is_expected.to parse('knows*2..3.location') }
  end
end
