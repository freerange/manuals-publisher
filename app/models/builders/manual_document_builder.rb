require "securerandom"

class ManualDocumentBuilder
  def initialize(factory_factory:)
    @factory_factory = factory_factory
  end

  def call(manual, attrs)
    document = @factory_factory
      .call(manual)
      .call(SecureRandom.uuid, [])

    document.update(attrs.reverse_merge(defaults))

    document
  end

private

  def defaults
    {
      document_type: "manual",
      minor_update: false,
      change_note: "New section added.",
    }
  end
end
