require "spec_helper"

module DeepCover
  RSpec.describe Analyser::Node do
    let(:node){ Node[<<-RUBY] }
      def foo(a = 42)
        raise unless a >= 42
      end
      foo(100)
      RUBY
    let(:analyser) {
      Analyser::Node.new(node.covered_code, allow_uncovered: allow_uncovered)
    }
    let(:results) { analyser.results }
    let(:not_executed) { results.select{|_node, runs| runs == 0}.keys }
    subject { not_executed.map(&:type) }

    context 'when allowing uncovered default arguments' do
      let(:allow_uncovered) { :default_argument }
      it { should == [:send] }
    end

    context 'when allowing uncovered default arguments' do
      let(:allow_uncovered) { :raise }
      it { should == [:int] }
    end
  end
end
