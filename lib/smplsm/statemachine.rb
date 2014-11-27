module Smplsm
  class StateMachine
    attr_reader :instance, :state_holder
    def initialize(instance, state_holder)
      @instance = instance
      @state_holder = state_holder
    end

    def self.default(state)
      define_method :default do
        state
      end

      define_method :set_default do
        return unless instance.public_send(state_holder).nil?
        instance.public_send("#{state_holder}=", state)
      end
    end

    def self.event(name, &blk)
    end
  end
end
