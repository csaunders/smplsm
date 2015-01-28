module Smplsm
  class StateMachine
    class TransitionError < StandardError; end

    attr_reader :instance, :state_holder
    def initialize(instance, state_holder)
      @instance = instance
      @state_holder = state_holder
      set_default
      setup_delegates
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
        instance.public_send("#{state_holder}=", new_state)
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
      dest = yield
      events[name] ||= []
      events[name] << dest
      define_method name do
        end_state = self.class.events[name].find do |state|
          start_states = self.class.transitions[state]
          state if start_states.include?(current_state)
        end
        raise TransitionError, "Invalid transition '#{name}' for '#{current_state}'" unless end_state
        set_state(end_state)
      end
    end

    def self.transition(from, to: nil)
      transitions[to] ||= []
      transitions[to] << from
      to
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
  end
end
