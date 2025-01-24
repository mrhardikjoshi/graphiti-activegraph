RSpec.describe Graphiti::ActiveGraph::Adapters::ActiveGraph::FunctionSideload do
  subject { LibraryResource.sideloads[:missing_books] }

  before(:all) do
    class BookResource < Graphiti::Resource
    end
    class LibraryResource < Graphiti::Resource
      has_one :missing_books, writable: false, class: Graphiti::ActiveGraph::Adapters::ActiveGraph::FunctionSideload, resource: BookResource do
        self.function_proc = ->() { 'searches.missing_books($opts)' }
        self.param_proc = ->() { { opts: { genres: 'Novel' } } }
        link {}
      end
    end
  end

  after(:all) do
    Object.send(:remove_const, :BookResource)
    Object.send(:remove_const, :LibraryResource)
  end

  describe 'sideload' do
    it 'has correct class' do
      expect(subject).to be_a(Graphiti::ActiveGraph::Adapters::ActiveGraph::FunctionSideload)
    end

    it 'correctly sets function proc' do
      expect(subject.function_proc.call).to eq('searches.missing_books($opts)')
    end

    it 'correctly sets function params' do
      expect(subject.param_proc.call).to eq({ opts: { genres: 'Novel' } })
    end
  end
end
