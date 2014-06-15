require 'ostruct'

module Opt
  #
  class Command
    #
    # Return {Set} of registered options for this command.
    #
    attr_reader :options

    attr_reader :commands

    attr_reader :name

    def initialize(name, opts = {})
      @name     = name.to_s
      @opts     = opts
      @options  = Set.new
      @commands = Set.new
    end

    # Register a new option.
    #
    # @example
    #   command.option '--help, -h'
    #
    # @see Option.new
    #
    def option(definition = nil, opts = {})
      option = Option.new(definition, opts)

      if commands.any?
        raise ArgumentError.new \
          'Can only have subcommands OR free-text arguments.'
      end

      if (opt = options.find{|o| o.collide?(option) })
        raise "Option `#{definition}' collides with already " \
              "registered option: #{opt}"
      else
        options << option
      end
    end

    def command(name, opts = {})
      if options.any?{|o| o.text? }
        raise ArgumentError.new \
          'Can only have subcommands OR free-text arguments.'
      end

      command = Command.new(name, opts)
      yield command if block_given?

      if commands.any?{|c| c.name == command.name }
        raise ArgumentError.new "Command `#{command.name}' already registered."
      end

      commands << command
      command
    end

    # Return hash with default values for all options.
    #
    def defaults
      Hash[options.map{|o| [o.name, o.default] }]
    end

    # Parses given list of command line tokens.
    #
    # @param argv [Array<String>] List of command line strings.
    #   Defaults to {ARGV}.
    #
    def parse(argv = ARGV)
      parse_argv! parse_tokens argv
    end

    def parse_argv!(argv)
      result = defaults

      parse_global_options!(argv, result)

      while argv.any?
        next if options.any?{|option| option.parse!(argv, result) }

        if argv.first.text?
          if (cmd = commands.find{|c| c.name == argv.first.value })
            argv.shift
            rst = cmd.parse_argv!(argv)

            return Result.new(name, result, rst)
          end
        end

        raise "Unknown option (#{argv.first.type}): #{argv.first}"
      end

      Result.new(name, result)
    end

    # Parse tokens from everywhere if option is global.
    #
    def parse_global_options!(argv, result)
      passed = []

      while argv.any?
        next if options.any? do |option|
          option.global? && option.parse!(argv, result)
        end

        passed << argv.shift
      end

      passed.each{|a| argv << a }
    end

    def parse_tokens(argv)
      tokens = []
      argv.each_with_index do |arg, index|
        if arg == '--'
          return tokens + argv[index + 1..-1].map{|a| Token.new(:text, a) }
        elsif arg[0..1] == '--'
          tokens << Token.new(:long, arg[2..-1])
        elsif arg[0] == '-'
          tokens << Token.new(:short, arg[1..-1])
        else
          tokens << Token.new(:text, arg)
        end
      end

      tokens
    end

    class Result
      attr_reader :data, :name, :command

      def initialize(name, data, command = nil)
        @data    = data
        @name    = name
        @command = command

        (class << self; self end).tap do |ec|
          data.each_pair do |key, value|
            next if respond_to?(key.to_s) || respond_to?("#{key}?")
            ec.send(:define_method, key.to_s)  { value }
            ec.send(:define_method, "#{key}?") { value }
          end
        end
      end
    end

    Token = Struct.new(:type, :value) do
      def text?
        type == :text
      end

      def short?
        type == :short
      end

      def to_s
        case type
          when :long
            "--#{value}"
          when :short
            "-#{value}"
          else
            value
        end
      end

      def inspect
        "<#{self.class}(#{type}):\"#{self}\">"
      end
    end
  end
end
