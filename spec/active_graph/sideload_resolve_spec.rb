RSpec.describe Graphiti::Scope do
  let(:object) { {} }
  let(:resource) { Graphiti::ActiveGraph::Resource.new }
  let(:query) { {} }
  let(:opts) { {} }

  describe '#bypass_scoping' do
    it 'does not call around_scoping when :preloaded is present in opts' do
      opts = {preloaded: {foo: 1}}

      expect(resource).not_to receive(:around_scoping)
      sideload_resolver = described_class.new(object, resource, query, opts)
    end

    it 'calls around_scoping when :preloaded is not present in opts' do
      expect(resource).to receive(:around_scoping)
      sideload_resolver = described_class.new(object, resource, query, opts)
    end
  end

  describe '#resolve' do
    let(:zero_results) { false }
    let(:params) { {} }
    let(:sideloads) { [] }
    let(:extra_fields) { {} }
    let(:query) { double(:query, zero_results?: zero_results, extra_fields:, params:, action: :get, sideloads:) }
    let(:results) { [Author.new] }
    let(:scope) { described_class.new(object, resource, query, opts) }
    before { allow(resource).to receive(:around_scoping).and_return(results) }

    it 'returns correct results' do
      expect(scope.resolve).to eq(results)
    end

    it 'assigns serializer' do
      expect(scope).to receive(:assign_serializer).with(results)
      scope.resolve
    end

    context 'with after_resolve callback' do
      let(:callback) { ->(results) {} }
      let(:opts) { { after_resolve: callback } }

      it 'calls it with results' do
        expect(callback).to receive(:call).with(results)
        scope.resolve
      end
    end

    context 'zero results' do
      let(:zero_results) { true }
      subject { scope.resolve }

      it { is_expected.to eq([]) }
    end

    context 'extra_fields preloading' do
      let(:params) { { extra_fields: { authors: [:posts_number]} } }
      let(:extra_fields) { {authors: [:posts_number]} }
      let(:query) { double(:query, zero_results?: zero_results, extra_fields:, params:, action: :get, sideloads:) }
      let(:results) { [author_with_post] }
      let(:resource) { AuthorResource.new }
      let(:author_with_post) { create(:author, :with_post) }
      let(:scope) do
        allow(resource).to receive(:around_scoping).and_return(results)
        described_class.new(object, resource, query, opts)
      end

      it 'assigns extra_field instance variable' do
        scope.resolve
        expect(author_with_post.instance_variable_get(:@posts_number)).to eq(1)
      end

      context 'without preload method' do
        before { allow(Author).to receive(:respond_to?).with(:preload_posts_number).and_return(false) }

        it 'does not assign extra_field instance variable' do
          expect(author_with_post.instance_variable_get(:@posts_number)).to eq(nil)
        end
      end

      context 'with sideloads' do
        let(:post_resource) { PostResource.new }
        let(:post_q) do
          double(:query, zero_results?: zero_results, extra_fields:, params:, action: :get,
            sideloads:, resource: post_resource)
        end
        let(:query) do
          double(:query, zero_results?: zero_results, extra_fields:, params:, action: :get,
            sideloads: { posts: post_q })
        end

        it 'assigns extra_field instance variable' do
          scope.resolve
          expect(author_with_post.instance_variable_get(:@posts_number)).to eq(1)
        end
      end

      context 'sideloads contain record for preload' do
        let(:author_q) { double(:query, zero_results?: zero_results, extra_fields:, params:, action: :get, sideloads:, resource:) }
        let(:comment_q) do
          double(:query, zero_results?: zero_results, extra_fields:, params:, action: :get, sideloads: { author: author_q }, resource: CommentResource.new)
        end
        let(:post_q) do
          double(:query, zero_results?: zero_results, extra_fields:, params:, action: :get, sideloads: { comments: comment_q }, resource: PostResource.new)
        end
        let(:query) { double(:query, zero_results?: zero_results, extra_fields:, params:, action: :get, sideloads: { posts: post_q }) }
        let(:author_with_post) { create(:author, :with_post_and_comment) }

        it 'assigns extra_field instance variable on all found records' do
          authors = scope.send(:collect_records_for_preload, :authors, results)
          expect(authors.size).to eq(2)
          scope.resolve
          expect(authors.map { |author| author.instance_variable_get(:@posts_number) }).to match_array([1, 2])
        end
      end

      context 'multiple extra_fields' do
        let(:extra_fields) { {authors: [:posts_number], comments: [:author_activity]} }
        let(:author_q) { double(:query, zero_results?: zero_results, extra_fields:, params:, action: :get, sideloads:, resource:) }
        let(:comment_q) do
          double(:query, zero_results?: zero_results, extra_fields:, params:, action: :get, sideloads: { author: author_q }, resource: CommentResource.new)
        end
        let(:post_q) do
          double(:query, zero_results?: zero_results, extra_fields:, params:, action: :get, sideloads: { comments: comment_q }, resource: PostResource.new)
        end
        let(:query) { double(:query, zero_results?: zero_results, extra_fields:, params:, action: :get, sideloads: { posts: post_q }) }
        let(:author_with_post) { create(:author, :with_post_and_comment) }

        it 'assigns extra_field instance variable on all author records' do
          authors = scope.send(:collect_records_for_preload, :authors, results)
          expect(authors.size).to eq(2)
          scope.resolve
          expect(authors.map { |author| author.instance_variable_get(:@posts_number) }).to match_array([1, 2])
        end

        it 'assigns extra_field instance variable on all comment records' do
          comments = scope.send(:collect_records_for_preload, :comments, results)
          expect(comments.size).to eq(1)
          scope.resolve
          expect(comments.first.instance_variable_get(:@author_activity)).to eq(3)
        end
      end

      context 'wrong extra_field type' do
        let(:extra_fields) { {wrong_type: [:posts_number]} }
        it 'does not assign extra_field instance variable' do
          scope.resolve
          expect(author_with_post.instance_variable_get(:@posts_number)).to eq(nil)
        end
      end

      context 'wrong extra_field name' do
        let(:extra_fields) { {authors: [:wrong_name]} }
        it 'does not assign extra_field instance variable' do
          scope.resolve
          expect(author_with_post.instance_variable_get(:@wrong_name)).to eq(nil)
        end
      end
    end
  end
end
