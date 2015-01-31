module Smplsm
  class StateMachine
    class StateDefinitionError < StandardError; end
    class TransitionError < StandardError; end
    class InvalidStateError < StandardError; end

    attr_reader :instance, :state_holder
    def initialize(instance, state_holder)
      @instance = instance
      @state_holder = state_holder
      set_default
      setup_delegates
      verify_state!
    end

    def self.default(state)
      define_method :default_state do
        state
      end

      define_method :set_default do
        return unless instance.public_send(state_holder).nil?
        instance.public_send("#{state_holder}=", state)
      end

      define_method :current_state do
        instance.public_send("#{state_holder}")
      end

      define_method :set_state do |new_state|
        instance.public_send("#{state_holder}=", new_state.name)
        new_state.proc.call(instance) if new_state.proc
      end
    end

    def self.transitions
      @transitions ||= {}
    end

    def self.events
      @events ||= {}
    end

    def self.event(name)
      raise "Invalid event, block required" unless block_given?
      events[name] ||= []
      events[name] << yield
      define_method name do
        end_state = self.class.events[name].find do |state|
          start_states = self.class.transitions[state.name]
          state if start_states.include?(current_state)
        end
        raise TransitionError, "Invalid transition '#{name}' for '#{current_state}'" unless end_state
        set_state(end_state)
      end
    end

    def self.transition(from, to: nil, &blk)
      raise StateDefinitionError if to.nil?
      transitions[to] ||= []
      transitions[to] << from
      TransitionDestination.new(to, blk)
    end

    private
    def setup_delegates
      delegate_methods = self.class.events.keys
      return if delegate_methods.all? {|m| instance.respond_to?(m)}
      code =<<-DEFN
      class << instance
        extend Forwardable
        attr_accessor :delegate
        #{delegate_methods.map do |m|
          "def_delegator :delegate, :#{m}"
        end.join("\n")}
      end
      DEFN
      eval code
      instance.delegate = self
    end

    def verify_state!
      return if current_state == default_state
      unless self.class.transitions.keys.include? current_state
        raise InvalidStateError
      end
    end

    class TransitionDestination
      attr_reader :name, :proc
      def initialize(name, proc)
        @name = name
        @proc = proc
      end
    end
  end
end
