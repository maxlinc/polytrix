require 'hashie/dash'
require 'hashie/extensions/coercion'

module Polytrix
  class FeatureNotImplementedError < StandardError
    def initialize(feature)
      super "Feature #{feature} is not implemented"
    end
  end
  class Implementor < Polytrix::ManifestSection
    class GitOptions < Polytrix::ManifestSection
      property :repo, required: true
      property :branch
      property :to

      def initialize(data)
        data = { repo: data } if data.is_a? String
        super
      end
    end

    include Polytrix::Logger
    include Polytrix::Core::FileSystemHelper
    include Polytrix::Runners::Executor
    property :name
    property :basedir, required: true
    property :language
    coerce_key :basedir, Pathname
    property :git
    coerce_key :git, GitOptions

    def initialize(data)
      data[:basedir] = File.absolute_path(data[:basedir])
      super
    end

    def clone
      Logging.mdc['implementor'] = name
      if git.nil? || git.repo.nil?
        logger.info "Skipping clone because there are no git options"
        return
      end
      branch = git.branch ||= 'master'
      target_dir = git.to ||= basedir
      if File.exists? target_dir
        logger.info "Skipping clone because #{target_dir} already exists"
      else
        clone_cmd = "git clone #{git.repo} -b #{branch} #{target_dir}"
        logger.info "Cloning: #{clone_cmd}"
        execute clone_cmd
      end
    end

    def bootstrap
      Logging.mdc['implementor'] = name
      banner "Bootstrapping #{name}"
      fail "Implementor #{name} has not been cloned" unless cloned?

      execute('./scripts/bootstrap', cwd: basedir, prefix: name)
    rescue Errno::ENOENT
      logger.warn "Skipping bootstrapping for #{name}, no script/bootstrap exists"
    end

    def build_challenge(challenge_data)
      challenge_data[:basedir] ||= basedir
      challenge_data[:implementor] ||= self
      challenge_data[:suite] ||= ''
      begin
        challenge_data[:source_file] ||= find_file basedir, challenge_data[:name]
        challenge_data[:source_file] = relativize(challenge_data[:source_file], challenge_data[:basedir])
      rescue Polytrix::Core::FileSystemHelper::FileNotFound
        challenge_data[:source_file] = nil
      end
      Challenge.new challenge_data
    end

    def cloned?
      File.directory? basedir
    end
  end
end
