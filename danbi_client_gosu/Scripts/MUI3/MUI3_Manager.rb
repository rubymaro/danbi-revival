module MUI3
  module Manager
    @components = []

    def self.add(component:)
      @components << component
    end

    def self.update
      for component in @components
        component.update()
      end
    end

    def self.draw
      for component in @components
        component.draw(0, 0)
      end
    end
  end
end