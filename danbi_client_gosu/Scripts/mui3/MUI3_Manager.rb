module MUI3
  module Manager
    @components = []

    def self.add(component:)
      @components << component
    end

    def self.update
      @components.each(&:update)
    end

    def self.draw
      @components.each(&:draw)
    end
  end
end