require 'ostruct'

module Opt
  #
  class Command
    #
    # List of registered options for this command.
    #
    # Can be used to add manually created {Option}s but use
    # with care as no collision or sanity checks are done.
    #
    # @return [Array<Option>] Option list.
    #
    attr_reader :options

    # List of registered subcommands.
    #
    # Can be used to add manually created {Command}s but use
    # with care as no collision or sanity checks are done.
    #
    # @return [Array<Command>] Subcommand list.
    #
    attr_reader :commands

    # The command name.
    #
    attr_reader :name

    # @api private
    #
    def initialize(name, opts = {})
      @name     = name.to_s.freeze
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
    # @param definition [String] The option definition. Usually a command
    #   separated list of dashed command line switches. If definition is
    #   not dashed a free-text argument will be given. See {Option#initialize}
    #   for more information.
    # @param opts [Hash] Option hash passed to {Option#initialize}.
    #   Used to specify a name, number of arguments, etc.
    #
    # @raise [ArgumentError] An {ArgumentError} is raised when a colliding
    #   option is already registered or you try do define a free-text
    #   option while already heaving a subcommand registered.
    #
    # @api public
    # @see Option.new
    #
    def option(definition = nil, opts = {}, &block)
      option = Option.new(definition, opts, &block)

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

    # Add a subcommand.
    #
    # A command can either have subcommands or free-text options.
    #
    # @example
    #   opt.command 'add' do |cmd|
    #     cmd.option '--num, -n'
    #   end
    #
    # @param name [String, Symbol, #to_s] The command name. This token
    #   will be used to match when parsing arguments.
    # @param opts [Hash] Options.
    #
    # @yield [command] Yield new command.
    # @yieldparam command [Command] The new command.
    #
    # @raise [ArgumentError] An {ArgumentError} will be raised when
    #   the command already has a free-text option or if a command
    #   with the same name is already registered.
    #
    # @return [Command] The new command.
    #
    # @api public
    # @see Opt::Command#initialize
    #
    def command(name, opts = {})
      if options.any?{|o| o.text? }
        raise ArgumentError.new \
          'Can only have subcommands OR free-text arguments.'
      end

      command = Command.new(name, opts)

      if commands.any?{|c| c.name == command.name }
        raise ArgumentError.new "Command `#{command.name}' already registered."
      end

      yield command if block_given?

      commands << command
      command
    end

    # Return hash with default values for all options.
    #
    # @return [Hash<String, Object>] Hash with option defaults.
    #
    # @api private
    #
    def defaults
      Hash[options.map{|o| [o.name, o.default] }]
    end

    # Parses given list of command line tokens.
    #
    # @example
    #   opt.parse %w(-fd command -x 56 --fuubar)
    #
    # @param argv [Array<String>] List of command line strings.
    #   Defaults to {ARGV}.
    #
    # @return [Result] Return a hash-like result object.
    #
    # @api public
    # @see Result
    #
    def parse(argv = ARGV)
      result = Result.new
      result.merge! defaults

      parse_argv! parse_tokens(argv.dup), result

      result
    end

    # @api private
    #
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

    private

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

    # A hash-like result object.
    #
    # Allow for method-access to all key-value pairs similar
    # to `OpenStruct`.
    #
    # @example
    #   result = opt.parse %w(--help --level=5 add --exec bash sh)
    #   result.help? #=> true
    #   result.level #=> "5"
    #   result.command #=> ["add"]
    #   result.exec #=> ["bash", "sh"]
    #
    class Result < Hash
      #
      # A list of command names.
      #
      # @return [Array<String>] List of commands.
      #
      attr_reader :command

      # @api private
      #
      def initialize
        @command = []
        super
      end

      # @api private
      #
      def respond_to_missing?(mth)
        if mth =~ /^(\w)\??$/ && key?($1)
          true
        else
          super
        end
      end

      # @api private
      #
      def method_missing(mth, *args, &block)
        if mth =~ /^(\w+)\??$/ && key?($1) && args.empty? && block.nil?
          fetch $1
        else
          super
        end
      end
    end

    # @api private
    #
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
