module ConsoleTest
  def self.run(&builder_block)
    builder = Builder.new(builder_block)
    builder
  end

  class Builder
  end
end
