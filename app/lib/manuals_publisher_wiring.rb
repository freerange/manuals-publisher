require "builders/manual_builder"
require "builders/manual_document_builder"
require "builders/specialist_document_builder"
require "dependency_container"
require "document_factory_registry"
require "footnotes_section_heading_renderer"
require "gds_api/publishing_api"
require "gds_api/publishing_api_v2"
require "gds_api/rummager"
require "govspeak_to_html_renderer"
require "markdown_attachment_processor"
require "marshallers/document_association_marshaller"
require "marshallers/manual_publish_task_association_marshaller"
require "repository_registry"
require "specialist_document_header_extractor"
require "specialist_document_repository"

$LOAD_PATH.unshift(File.expand_path("../..", "app/services"))

# rubocop:disable ConstantName
ManualsPublisherWiring ||= DependencyContainer.new do
  define_instance(:specialist_document_govspeak_header_extractor) {
    ->(doc) {
      SpecialistDocumentHeaderExtractor.new(
        GovspeakHeaderExtractor.create,
        doc,
      )
    }
  }

  define_instance(:manual_renderer) {
    ->(manual) {
      GovspeakToHTMLRenderer.create.call(manual)
    }
  }

  define_instance(:specialist_document_renderer) {
    ->(doc) {
      pipeline = [
        MarkdownAttachmentProcessor.method(:new),
        ManualsPublisherWiring.get(:specialist_document_govspeak_header_extractor),
        GovspeakToHTMLRenderer.create,
      ]

      pipeline.reduce(doc) { |current_doc, next_renderer|
        next_renderer.call(current_doc)
      }
    }
  }

  define_instance(:manual_document_renderer) {
    ->(doc) {
      pipeline = [
        MarkdownAttachmentProcessor.method(:new),
        ManualsPublisherWiring.get(:specialist_document_govspeak_header_extractor),
        GovspeakToHTMLRenderer.create,
        FootnotesSectionHeadingRenderer.create,
      ]

      pipeline.reduce(doc) { |current_doc, next_renderer|
        next_renderer.call(current_doc)
      }
    }
  }

  define_singleton(:rummager_api) {
    GdsApi::Rummager.new(Plek.new.find("search"))
  }

  define_singleton(:publishing_api) {
    GdsApi::PublishingApi.new(
      Plek.new.find("publishing-api"),
      bearer_token: ENV["PUBLISHING_API_BEARER_TOKEN"] || "example",
      timeout: 30
    )
  }

  define_singleton(:publishing_api_v2) {
    GdsApi::PublishingApiV2.new(
      Plek.new.find("publishing-api"),
      bearer_token: ENV["PUBLISHING_API_BEARER_TOKEN"] || "example"
    )
  }

  define_singleton(:organisations_api) {
    require "gds_api/organisations"
    GdsApi::Organisations.new(ORGANISATIONS_API_BASE_PATH)
  }

  define_singleton(:organisation_fetcher) {
    organisations = {}
    ->(organisation_slug) {
      organisations[organisation_slug] ||= ManualsPublisherWiring.get(:organisations_api).organisation(organisation_slug)
    }
  }
end
# rubocop:enable ConstantName
