require 'scripts/block_node'
require 'scripts/snake'

def step(engine, delta)
  @state_manager ||= begin
    Moon::StateManager.new(engine).tap do |s|
      s.push States::Snake
    end
  end
  @state_manager.step delta
end
