class Configuration
  def call(app_config)
    Heroes::Configuration.new.call(app_config[:event_store], app_config[:command_bus], app_config[:query_bus])
  end

  private
end
