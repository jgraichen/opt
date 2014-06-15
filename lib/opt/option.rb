module Opt
  #
  # A command line option consisting of multiple switches,
  # possibly arguments and options about allowed numbers etc.
  #
  # @api private
  #
  class Option
    #
    # Option's name.
    #
    # @return [String] Frozen name string.
    #
    attr_reader :name

    # Set of switches triggering this option.
    #
    # Avoid direct manipulation.
    #
    # @return [Set<Switch>] Set of switches.
    #
    attr_reader :switches

    # Options passed to {#initialize}.
    #
    # @return [Hash] Option hash.
    #
    attr_reader :options

    # Option default value.
    #
    # @return [Object] Default value.
    #
    attr_reader :default

    # Option value returned if switch is given.
    #
    # Will be ignored if option takes arguments.
    #
    # @return [Object] Option value.
    #
    attr_reader :value

    # Number of arguments as a range.
    #
    # @return [Range] Argument number range.
    #
    attr_reader :nargs

    def initialize(definition, options = {})
      @options  = options
      @default  = options.fetch(:default, nil)
      @value    = options.fetch(:value, true)
      @nargs    = Option.parse_nargs options.fetch(:nargs, 0)

      if definition.to_s =~ /\A[[:word:]]+\z/
        @switches = Set.new
        @name     = options.fetch(:name, definition).to_s.freeze

        unless nargs.first > 0 || nargs.size > 1
          raise 'A text option must consist of at least one argument.'
        end
      else
        @switches = Switch.parse(definition)
        @name     = options.fetch(:name, switches.first.name).to_s.freeze
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
      name == option.name ||
      switches.any?{|s1| option.switches.any?{|s2| s1.eql?(s2) }}
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
      if nargs == (0..0)
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
          if nargs == (1..1)
            result[name] = args.first
          else
            result[name] = args
          end
        else
          # raise Opt::MissingArgument
          raise "wrong number of arguments (#{args.size} for #{nargs})"
        end
      end
    end

    class << self
      def parse_nargs(num)
        case num
          when Range
            parse_nargs_range(num)
          when Array
            parse_nargs_array(num)
          else
            parse_nargs_obj(num)
        end
      end

      def parse_nargs_obj(obj)
        case obj.to_s.downcase
          when '+'
            1..Float::INFINITY
          when '*', 'inf', 'infinity'
            0..Float::INFINITY
          else
            i = Integer(obj.to_s)
            parse_nargs_range i..i
        end
      end

      def parse_nargs_range(range)
        if range.first > range.last
          if range.exclude_end?
            range = Range.new(range.last + 1, range.first)
          else
            range = Range.new(range.last, range.first)
          end
        end

        if range.first < 0
          raise RuntimeError.new 'Argument number must not be less than zero.'
        end

        range
      end

      def parse_nargs_array(obj)
        if obj.size == 2
          parse_nargs_range Range.new(parse_nargs_array_obj(obj[0]),
                                      parse_nargs_array_obj(obj[1]))
        else

          raise ArgumentError.new \
            'Argument number array count must be exactly two.'
        end
      end

      def parse_nargs_array_obj(obj)
        case obj.to_s.downcase
          when '*', 'inf', 'infinity'
            Float::INFINITY
          else
            Integer(obj.to_s)
        end
      end
    end
  end
end
