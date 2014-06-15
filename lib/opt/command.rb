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
      @options  = []
      @commands = []
    end

    # Register a new option.
    #
    # @example An option named "help" triggered on "--help" or "-h"
    #   command.option '--help, -h'
    #
    # @example An option with exactly one argument
    #   command.option '--level, -l', nargs: 1
    #
    # @example An option with 2 or more arguments
    #   command.option '--files', nargs: [2, :inf]
    #   command.option '--files', nargs: [2, :infinity]
    #   command.option '--files', nargs: [2, '*']
    #
    # @example An option with 2 to 4 arguments and a specific name
    #   command.option '--sum, -s, -a', nargs: (2..4), name: :accumulate
    #
    # @example An option with 0 or more arguments
    #   command.option '-x', nargs: '*'
    #
    # @example An option with 1 or more arguments
    #   command.option '-x', nargs: '+'
    #
    # @example A free-text option
    #   command.option 'file', name: :files, nargs: '*'
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
      result = Result.new
      result.merge! defaults

      parse_argv! parse_tokens(argv), result

      result
    end

    def parse_argv!(argv, result, options = [])
      options += self.options

      while argv.any?
        next if options.any?{|o| o.parse!(argv, result) }

        if argv.first.text?
          if (cmd = commands.find{|c| c.name == argv.first.value })
            result.command << argv.shift.value
            cmd.parse_argv!(argv, result, options)
            next
          end
        end

        raise "Unknown option (#{argv.first.type}): #{argv.first}"
      end
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

    class Result < Hash
      attr_reader :command

      def initialize
        @command = []
        super
      end

      def respond_to_missing?(mth)
        if mth =~ /^(\w)\??$/ && key?($1)
          true
        else
          super
        end
      end

      def method_missing(mth, *args, &block)
        if mth =~ /^(\w+)\??$/ && key?($1) && args.empty? && block.nil?
          fetch $1
        else
          super
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
