module Polytrix
  module Core
    describe FileFinder do
      subject(:finder) do
        Object.new.extend(Polytrix::Core::FileFinder)
      end

      it 'finds files within the search path' do
        search_path = 'spec/fixtures/src-doc'
        file = finder.find_file search_path, 'quine'
        expect(file.relative_path_from path(search_path)).to eq(path('quine.md.erb'))
      end

      it 'raises FileNotFound except if a file is not found' do
        expect { finder.find_file 'spec/fixtures/src-doc', 'quinez' }.to raise_error FileFinder::FileNotFound
      end

      private
      def path(p)
        Pathname.new p
      end
    end
  end
end
