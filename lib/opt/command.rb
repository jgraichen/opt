require 'ostruct'

module Opt
  #
  class Command
    #
    # Return {Set} of registered options for this command.
    #
    attr_reader :options

    def initialize(name, opts = {})
      @name    = name
      @opts    = opts
      @options = Set.new
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

      if (opt = options.find{|o| o.collide?(option) })
        raise "Option `#{definition}' collides with already " \
              "registered option: #{opt}"
      else
        options << option
      end
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
      result = defaults
      argv   = parse_tokens(argv)

      while argv.any?
        next if options.any?{|option| option.parse!(argv, result) }
        raise "Unknown option (#{argv.first.type}): #{argv.first}"
      end

      Result.new(result)
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
      attr_reader :data

      def initialize(data)
        @data = data

        (class << self; self end).tap do |ec|
          data.each_pair do |key, value|
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
