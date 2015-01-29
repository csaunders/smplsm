module Smplsm
  module Stateful
    module ClassMethods
      def state_on(state, using: nil)
        @state_machines ||= {}
        raise "Statemachine #{state} is already defined" if @state_machines[state]
        raise "StateMachine cannot be nil" if using.nil?
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
