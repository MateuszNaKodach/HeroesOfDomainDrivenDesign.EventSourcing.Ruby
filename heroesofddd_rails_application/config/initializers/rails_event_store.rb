require "rails_event_store"
require "aggregate_root"
require "arkency/command_bus"
require "building_blocks/infrastructure/event_store/event_registry"
require "building_blocks/infrastructure/command_bus/metadata_command_bus"
require "building_blocks/infrastructure/command_bus/recording_command_bus"

Rails.configuration.to_prepare do
  Rails.configuration.event_store = RailsEventStore::JSONClient.new
  Rails.configuration.event_registry = BuildingBlocks::Infrastructure::EventStore::EventRegistry.new
  Rails.configuration.command_bus = command_bus_instance(Rails.configuration.event_store)
  Rails.configuration.query_bus = Arkency::CommandBus.new

  AggregateRoot.configure do |config|
    config.default_event_store = Rails.configuration.event_store
  end

  # Subscribe event handlers below
  Rails.configuration.event_store.tap do |store|
    # store.subscribe(InvoiceReadModel.new, to: [InvoicePrinted])
    # store.subscribe(lambda { |event| SendOrderConfirmation.new.call(event) }, to: [OrderSubmitted])
    # store.subscribe_to_all_events(lambda { |event| Rails.logger.info(event.event_type) })

    store.subscribe_to_all_events(RailsEventStore::LinkByEventType.new)
    store.subscribe_to_all_events(RailsEventStore::LinkByCorrelationId.new)
    store.subscribe_to_all_events(RailsEventStore::LinkByCausationId.new)
  end

  # Register command handlers below
  # Rails.configuration.command_bus.tap do |bus|
  #   bus.register(PrintInvoice, Invoicing::OnPrint.new)
  #   bus.register(SubmitOrder, ->(cmd) { Ordering::OnSubmitOrder.new.call(cmd) })
  # end

  Configuration.new.call(Rails.configuration.event_store, Rails.configuration.command_bus, Rails.configuration.query_bus, Rails.configuration.event_registry)
end

def command_bus_instance(event_store)
  arkency_command_bus = Arkency::CommandBus.new
  metadata_command_bus = ::BuildingBlocks::Infrastructure::CommandBus::MetadataCommandBus.new(arkency_command_bus, event_store)
  if Rails.env.test? # todo: do not introduce test noise in production test
    BuildingBlocks::Infrastructure::CommandBus::RecordingCommandBus.new(metadata_command_bus)
  else
    metadata_command_bus
  end
end
