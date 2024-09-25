class RecordingCommandBus
  attr_reader :recorded

  def initialize(decorated)
    @recorded = []
    @decorated = decorated
  end

  def call(command)
    @recorded << command
    @decorated.call(command)
  end

  def reset
    @recorded = []
  end
end
