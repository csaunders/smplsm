gem "minitest"
require "minitest/autorun"
require "smplsm"

class TestSmplsm < Minitest::Test

  class EnableDisable < Smplsm::StateMachine
    default :enabled
    event :enable do
      transition :enabled => :disabled
    end

    event :disable do
      transition :disabled => :enabled
    end
  end

  class SomeObject
    extend Smplsm::Stateful
    state_on :state, using: EnableDisable
  end
  def test_sanity
    flunk "write tests or I will kneecap you"
  end
end
