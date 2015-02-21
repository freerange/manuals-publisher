require "formatters/medical_safety_alert_publication_alert_formatter"
require "formatters/medical_safety_alert_indexable_formatter"
require "markdown_attachment_processor"

class MedicalSafetyAlertObserversRegistry < AbstractSpecialistDocumentObserversRegistry

private
  def format_document_as_artefact(document)
    MedicalSafetyAlertArtefactFormatter.new(document)
  end

  def content_api_exporter
    SpecialistPublisherWiring.get(:medical_safety_alert_content_api_exporter)
  end

  def format_document_for_indexing(document)
    MedicalSafetyAlertIndexableFormatter.new(
      MarkdownAttachmentProcessor.new(document)
    )
  end

  def publication_alert_formatter(document)
    MedicalSafetyAlertPublicationAlertFormatter.new(
      url_maker: url_maker,
      document: document,
    )
  end
end
