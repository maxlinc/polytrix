class ThorSpy
  attr_reader :stdout, :stdin, :stderr
  attr_accessor :app

  def self.on(app, kernel = Kernel)
    new([], StringIO.new, StringIO.new, StringIO.new, kernel).with_app(app)
  end

  # Allow everything fun to be injected from the outside while defaulting to normal implementations.
  def initialize(argv = [], stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = Kernel)
    @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
  end

  def app
    fail 'You must set the Thor app via ThorSpy.on or #with_app before calling execute!' unless @app
    @app
  end

  def with_app(app)
    fail ArgumentError, 'app should be a class' unless app.is_a? Class
    fail ArgumentError, 'app should be a subclass of Thor' unless app < Thor
    @app = app
    self
  end

  def execute!
    exit_code = begin
      # Thor accesses these streams directly rather than letting them be injected, so we replace them...
      $stderr = @stderr
      $stdin = @stdin
      $stdout = @stdout

      fail 'You must set the Thor app' if @app.nil?

      # Run our normal Thor app the way we know and love.
      app.start(@argv)

      # Thor::Base#start does not have a return value, assume success if no exception is raised.
      0
    rescue StandardError => e
      # The ruby interpreter would pipe this to STDERR and exit 1 in the case of an unhandled exception
      b = e.backtrace
      b.unshift("#{b.shift}: #{e.message} (#{e.class})")
      @stderr.puts(b.map { |s| "\tfrom #{s}" }.join("\n"))
      1
    rescue SystemExit => e
      e.status
    ensure
      # ...then we put them back.
      $stderr = STDERR
      $stdin = STDIN
      $stdout = STDOUT
    end

    # Proxy our exit code back to the injected kernel.
    @kernel.exit(exit_code)
  end

  def method_missing(meth, *args)
    # I don't think a block makes sense, unless it's stdin.
    return super if block_given?

    @argv = [meth.to_s].concat(args)
    execute!
  end
end
