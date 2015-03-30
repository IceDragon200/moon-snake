#
# moon/core/state/snake
#   A Snake clone, in Moon!
class Snake < BlockLink
  class Body < Snake
  end

  def grow
    b = Body.new
    b.position.set tail.position
    stack_push b
  end

  alias :tail :stack_bottom
  alias :length :stack_size
end

class Glob
  attr_accessor :position
  attr_accessor :is_main
  attr_accessor :points

  def initialize(*args)
    @position = Moon::Vector2.new(*args)
    @points = 0
  end
end

module States
  class Snake < ::State
    include Moon

    def init
      super
      @width  = (screen.width / 16).to_i
      @height = (screen.height / 16).to_i
      @height -= 2 # making space for the text_score
      @field = Moon::Rect.new(0, 24, @width * 16, @height * 16)
      puts "Board Size is: #{@width} x #{@height}"
      init_snake
      init_spriteset
      init_texts
      @cell_width = @spritesheet.cell_width
      @cell_height = @spritesheet.cell_height
      setup

      @input = Moon::Input::Observer.new
      engine.input.register @input
      @input.on :press, :down do
        @dir = 2
      end

      @input.on :press, :left do
        @dir = 4
      end

      @input.on :press, :right do
        @dir = 6
      end

      @input.on :press, :up do
        @dir = 8
      end
    end

    def init_snake
      @snake = ::Snake.new
    end

    def init_spriteset
      @spritesheet = Moon::Spritesheet.new('resources/blocks/block_16x16_007.png', 16, 16)
    end

    def init_texts
      @text_score = Moon::Font.new('resources/fonts/vera/Vera.ttf', 24)
      @text_color = Moon::Vector4.new 1.0, 1.0, 1.0, 1.0
    end

    def setup
      @dir = 6
      @time = 15
      @points = 0
      @globs = []
      add_main_glob # add the very first main glob
      refresh_points_s
    end

    def available_pos
      return rand(@width), rand(@height)
    end

    def unoccupied_pos?(x, y)
      expected = Moon::Vector2.new(x, y)
      for obj in (@globs + @snake.stack)
        return false if obj.position == expected
      end
      return true
    end

    def add_glob
      while pos = available_pos
        break if unoccupied_pos?(*pos)
      end
      glob = Glob.new(*pos)
      @globs.push(glob)
      return glob
    end

    def add_main_glob
      add_glob.is_main = true
    end

    def new_bonus_glob
      add_glob.is_main = false
    end

    def refresh_points_s
      @points_s = "Points: #{@points}"
    end

    def render
      super
      last_i = @snake.length - 1
      for glob in @globs
        @spritesheet.render(@field.x + glob.position.x * @cell_width,
                            @field.y + glob.position.y * @cell_height, 0, 4)
      end
      @snake.each_with_index do |body, i|
        x, y = *body.position
        if i == 0
          sp_i = 0
        elsif i == last_i
          sp_i = 1
        else
          sp_i = 2
        end
        @spritesheet.render(@field.x + x * @cell_width,
                            @field.y + y * @cell_height, 1, sp_i)
      end
      @text_score.render(0, @text_score.size, 0, @points_s, @text_color)
    end

    def update(delta)
      super delta
      if @ticks % @time == 0
        @snake.move_straight(@dir)
        @snake.position.x %= @width
        @snake.position.y %= @height
        if solve_collision
          check_globs
          @points += 1
          refresh_points_s
        end
      end
    end

    def gameover
      puts "Gameover"
      puts "Your Score: #{@points}"
      state_manager.pop
    end

    def solve_collision
      for body in @snake.stack_children
        if @snake.position == body.position
          gameover
          return false
        end
      end
      return true
    end

    def check_globs
      removed_globs = []
      for glob in @globs
        if glob.position == @snake.position
          @points += glob.points
          if glob.is_main
            @snake.grow
            add_main_glob
          end
          removed_globs.push(glob)
        end
      end
      removed_globs.each do |glob|
        @globs.delete(glob)
      end
    end
  end
end
