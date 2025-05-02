describe Graphiti::ActiveGraph::Query do
  let(:query) { Graphiti::Query.new(resource, params, association_name, nested_include, parents, action) }
  let(:resource) { AuthorResource.new }
  let(:params) { {} }
  let(:association_name) {}
  let(:nested_include) {}
  let(:parents) {}
  let(:action) {}

  describe '#links?' do
    subject { query.links? }

    context 'when absent' do
      let(:params) { {} }

      it { is_expected.to be true }
    end

    context 'when false' do
      let(:params) { { links: 'false' } }

      it { is_expected.to be false }
    end

    context 'when true' do
      let(:params) { { links: 'true' } }

      it { is_expected.to be true }

      context 'when xml format' do
        let(:params) { { links: 'true', format: 'xml' } }

        it { is_expected.to be false }
      end
    end
  end

  describe '#pagination_links?' do
    subject { query.pagination_links? }

    context 'when absent' do
      let(:params) { {} }

      it { is_expected.to be true }
    end

    context 'when false' do
      let(:params) { { pagination_links: 'false' } }

      it { is_expected.to be false }
    end

    context 'when true' do
      let(:params) { { pagination_links: 'true' } }

      it { is_expected.to be true }

      context 'when :show action' do
        let(:action) { :show }

        it { is_expected.to be false }
      end
    end
  end
end
