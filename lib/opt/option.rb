module Opt
  #
  # A command line option consisting of multiple switches,
  # possibly arguments and options about allowed numbers etc.
  #
  class Option
    #
    # Option's name.
    #
    attr_reader :name

    # Set of switches triggering this option.
    #
    attr_reader :switches

    # Options passed to {#initialize}.
    #
    attr_reader :options

    # Option default value.
    #
    attr_reader :default

    # Option value returned if switch is given.
    #
    # Will be ignored if option takes arguments.
    #
    attr_reader :value

    # Number of arguments as a range.
    #
    attr_reader :nargs

    def initialize(definition, options = {})
      @options  = options
      @default  = options.fetch(:default, nil)
      @value    = options.fetch(:value, true)
      @nargs    = Option.parse_nargs options.fetch(:nargs, 0)

      if definition.to_s =~ /\A[[:word:]]+\z/
        @switches = Set.new
        @name     = options.fetch(:name, definition).to_s

        unless nargs.first > 0 || nargs.size > 1
          raise 'A text option must consist of at least one argument.'
        end
      else
        @switches = Switch.parse(definition)
        @name     = options.fetch(:name, switches.first.name).to_s
      end
    end

    # Check if option is triggered by at least on CLI switch.
    #
    def switch?
      switches.any?
    end

    # Check if option is a free-text option.
    #
    def text?
      !switch?
    end

    def collide?(option)
      name == option.name || !switches.disjoint?(option.switches)
    end

    def parse!(argv, result)
      if text?
        parse_text!(argv, result)
      else
        parse_switches!(argv, result)
      end
    end

    def parse_text!(argv, result)
      return false unless argv.first.text?

      parse_args!(argv, result)
      true
    end

    def parse_switches!(argv, result)
      switches.each do |switch|
        next unless switch.match!(argv)

        parse_args!(argv, result)
        return true
      end

      false
    end

    def parse_args!(argv, result)
      if nargs.first == 0 && nargs.last == 0
        result[name] = value
      else
        args = []
        if argv.any? && argv.first.text?
          while argv.any? && argv.first.text? && args.size < nargs.last
            args << argv.shift.value
          end
        elsif argv.any? && argv.first.short?
          args << argv.shift.value
        end

        if nargs.include?(args.size)
          if nargs.first == 1 && nargs.last == 1
            result[name] = args.first
          else
            result[name] = args
          end
        else
          # raise Opt::MissingArgument
          raise "ArgumentError: wrong number of arguments (#{args.size} for #{nargs})"
        end
      end
    end

    class << self
      def parse_nargs(num)
        unless num.is_a?(Range)
          return parse_nargs(Range.new(Integer(num), Integer(num)))
        end

        if num.first > num.last
          if num.exclude_end?
            num = Range.new(num.last + 1, num.first)
          else
            num = Range.new(num.last, num.first)
          end
        end

        if num.first < 0
          raise RuntimeError.new 'Argument number must not be less than zero.'
        end

        num
      end
    end
  end
end
