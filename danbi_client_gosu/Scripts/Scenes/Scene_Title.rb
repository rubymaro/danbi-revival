module Scene
  class Title < Scene::Base
    def initialize
      @image_title = Gosu::Image.new("Graphics/Titles/title_1920_1080.png")
      @title_scale_x = Config::WINDOW_WIDTH / @image_title.width.to_f
      @title_scale_y = Config::WINDOW_HEIGHT / @image_title.height.to_f
    end

    def update

    end

    def draw
      @image_title.draw(0, 0, 0, @title_scale_x, @title_scale_y)
    end
  end
end