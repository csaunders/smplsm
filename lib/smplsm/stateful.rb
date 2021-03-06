module Smplsm
  module Stateful
    class StateRedefinitionError < StandardError; end
    class InvalidStateMachineError < StandardError; end

    module ClassMethods
      def new *args
        super.tap do |instance|
          @state_machines.each do |field, machine|
            machine.new(instance, field)
          end
        end
      end

      def state_on(state, using: nil)
        @state_machines ||= {}
        raise StateRedefinitionError, "A State Machine for #{state} is already defined" if @state_machines[state]
        raise InvalidStateMachineError, "State Machine cannot be nil" if using.nil?
        @state_machines[state] = using
      end

      def sm_for(state)
        @state_machines[state]
      end
    end

    def self.included(base)
      base.extend ClassMethods
    end
  end
end
