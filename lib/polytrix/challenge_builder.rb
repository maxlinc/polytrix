module Polytrix
  class ChallengeBuilder
    include Polytrix::Core::FileFinder

    def initialize(implementor)
      @implementor = implementor
    end

    def build(challenge_data)
      challenge_data[:source_file] ||= find_file @implementor.basedir, challenge_data[:name]
      challenge_data[:basedir] ||= @implementor.basedir
      Challenge.new challenge_data
    end
  end
end