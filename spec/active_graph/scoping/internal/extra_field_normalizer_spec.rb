describe Graphiti::ActiveGraph::Scoping::Internal::ExtraFieldNormalizer do
  describe '#normalize' do
    let(:resource) { AuthorResource.new }
    let(:extra_attributes) { { authors: [:recent_three_post_titles] } }
    let(:includes) { {posts: {author: {}}}}
    subject { described_class.new(extra_attributes).normalize(resource, includes) }

    context 'when preload value present' do
      it { is_expected.to eq(['posts', 'posts.author.posts']) }
    end

    context 'when preload value absent' do
      before do
        AuthorResource.config[:extra_attributes][:recent_three_post_titles] = { hook: -> {} }
      end

      it { is_expected.to eq([]) }
    end

    context 'when extra_attribute preload parameter absent' do
      before do
        AuthorResource.config[:extra_attributes][:recent_three_post_titles] = {}
      end

      it { is_expected.to eq([]) }
    end

    context 'when extra_attribute does not exist' do
      let(:extra_attributes) { { authors: [:recent_three_posts] } }

      it { is_expected.to eq([]) }
    end

    context 'when preload value contains *' do
      before do
        AuthorResource.config[:extra_attributes][:recent_three_post_titles][:preload] = 'posts*'
      end

      it { is_expected.to eq(['posts*', 'posts.author.posts*']) }
    end

    context 'when multiple extra_attributes' do
      before do
        AuthorResource.config[:extra_attributes][:recent_three_post_titles][:preload] = 'posts'
      end
      let(:extra_attributes) { { authors: [:recent_three_post_titles], posts: [:full_post_title] } }

      it { is_expected.to eq(['posts', 'posts.author', 'posts.author.posts']) }
    end

    context 'when no extra_attributes' do
      let(:extra_attributes) {}

      it { is_expected.to eq([]) }
    end

    context 'when wrong association passed in includes' do
      before do
        AuthorResource.config[:extra_attributes][:recent_three_post_titles][:preload] = 'posts'
      end
      let(:includes) { {posts: {comments: {}}}}
      let(:extra_attributes) { { authors: [:recent_three_post_titles], posts: [:full_post_title] } }

      it { is_expected.to eq(['posts', 'posts.author']) }
    end

    context 'when preload value is a hash' do
      before do
        AuthorResource.config[:extra_attributes][:recent_three_post_titles][:preload] = { posts: :author }
      end

      it { is_expected.to eq(['posts.author', 'posts.author.posts.author']) }
    end

    context 'when preload value is a nested hash' do
      before do
        AuthorResource.config[:extra_attributes][:recent_three_post_titles][:preload] = { posts: { comment: :author } }
      end

      it { is_expected.to eq(['posts.comment.author', 'posts.author.posts.comment.author']) }
    end

    context 'when preload value is an array' do
      before do
        AuthorResource.config[:extra_attributes][:recent_three_post_titles][:preload] = [:posts, 'comment']
      end

      it { is_expected.to eq(['posts', 'comment', 'posts.author.posts', 'posts.author.comment']) }
    end
  end
end
