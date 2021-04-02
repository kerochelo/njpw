module MyFaker
  class Name < Base
    flexible :name

    class << self
      def name
        fetch('name')
      end
    end
  end
end
