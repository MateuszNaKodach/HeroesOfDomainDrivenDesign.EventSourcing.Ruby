require "rails_event_store"
require "aggregate_root"
require "arkency/command_bus"
require_relative "../../lib/building_blocks/infrastructure/event_store/event_registry"

Rails.configuration.to_prepare do
  Rails.configuration.event_store = RailsEventStore::JSONClient.new
  Rails.configuration.event_registry = BuildingBlocks::Infrastructure::EventStore::EventRegistry.new
  Rails.configuration.command_bus = Arkency::CommandBus.new
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

  Configuration.new.call(Rails.configuration.event_store, Rails.configuration.command_bus, Rails.configuration.query_bus, Rails.configuration.event_registry) #unless Rails.env.test?

end
