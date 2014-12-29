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

    include Polytrix::Logging
    include Polytrix::Util::FileSystem
    property :name
    property :basedir, required: true
    property :language
    coerce_key :basedir, Pathname
    property :git
    coerce_key :git, GitOptions

    attr_accessor :runner

    def initialize(data)
      data[:basedir] = File.absolute_path(data[:basedir])
      super
    end

    def runner
      @runner ||= Psychic::Runner.new(cwd: basedir, logger: logger)
    end

    def logger
      @logger ||= Polytrix::Logger.new_logger(self)
    end

    def clone
      if git.nil? || git.repo.nil?
        logger.info 'Skipping clone because there are no git options'
        return
      end
      branch = git.branch ||= 'master'
      target_dir = git.to ||= basedir
      if File.exist? target_dir
        logger.info "Skipping clone because #{target_dir} already exists"
      else
        clone_cmd = "git clone #{git.repo} -b #{branch} #{target_dir}"
        logger.info "Cloning: #{clone_cmd}"
        Polytrix.global_runner.execute(clone_cmd)
      end
    end

    def bootstrap
      banner "Bootstrapping #{name}"
      fail "Implementor #{name} has not been cloned" unless cloned?
      runner.execute_task('bootstrap')
    rescue Psychic::Runner::TaskNotImplementedError
      logger.warn "Skipping bootstrapping for #{name}, no bootstrap task exists"
    end

    def build_challenge(challenge_data)
      challenge_data[:basedir] ||= basedir
      challenge_data[:implementor] ||= self
      challenge_data[:suite] ||= ''
      begin
        challenge_data[:source_file] ||= find_file basedir, challenge_data[:name]
        challenge_data[:source_file] = relativize(challenge_data[:source_file], challenge_data[:basedir])
      rescue Errno::ENOENT
        challenge_data[:source_file] = nil
      end
      Challenge.new challenge_data
    end

    def cloned?
      File.directory? basedir
    end
  end
end
