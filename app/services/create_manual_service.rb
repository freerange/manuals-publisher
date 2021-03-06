class CreateManualService
  def initialize(manual_repository:, manual_builder:, listeners:, attributes:)
    @manual_repository = manual_repository
    @manual_builder = manual_builder
    @listeners = listeners
    @attributes = attributes
  end

  def call
    if manual.valid?
      persist
      notify_listeners
    end

    manual
  end

private

  attr_reader(
    :manual_repository,
    :manual_builder,
    :listeners,
    :attributes,
  )

  def manual
    @manual ||= manual_builder.call(attributes)
  end

  def persist
    manual_repository.store(manual)
  end

  def notify_listeners
    reloaded_manual = manual_repository[manual.id]
    listeners.each do |listener|
      listener.call(reloaded_manual)
    end
  end
end
