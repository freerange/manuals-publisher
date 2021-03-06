class ManualSectionPublishingAPIExporter
  include PublishingAPIUpdateTypes

  def initialize(export_recipent, organisation, document_renderer, manual, document, update_type: nil)
    @export_recipent = export_recipent
    @organisation = organisation
    @document_renderer = document_renderer
    @manual = manual
    @document = document
    @update_type = update_type
    check_update_type!(@update_type)
  end

  def call
    export_recipent.call(content_id, exportable_attributes)
  end

private

  attr_reader :export_recipent, :document_renderer, :organisation, :manual, :document

  def content_id
    document.id
  end

  def base_path
    "/#{rendered_document_attributes.fetch(:slug)}"
  end

  def exportable_attributes
    {
      base_path: base_path,
      schema_name: "manual_section",
      document_type: "manual_section",
      title: rendered_document_attributes.fetch(:title),
      description: rendered_document_attributes.fetch(:summary),
      update_type: update_type,
      publishing_app: "manuals-publisher",
      rendering_app: "manuals-frontend",
      routes: [
        {
          path: base_path,
          type: "exact",
        }
      ],
      details: details,
      locale: "en",
    }.merge(optional_exportable_attributes)
  end

  def optional_exportable_attributes
    attrs = {}
    if manual.originally_published_at.present?
      attrs[:first_published_at] = manual.originally_published_at.iso8601
      attrs[:public_updated_at] = manual.originally_published_at.iso8601 if manual.use_originally_published_at_for_public_timestamp?
    end
    attrs
  end

  def details
    {
      body: [
        {
          content_type: "text/govspeak",
          content: document.attributes.fetch(:body)
        },
        {
          content_type: "text/html",
          content: rendered_document_attributes.fetch(:body)
        }
      ],
      manual: {
        base_path: "/#{manual.attributes.fetch(:slug)}",
      },
      organisations: [
        organisation_info
      ],
    }.tap do |details_hash|
      details_hash[:attachments] = attachments if document.attachments.present?
    end
  end

  def attachments
    document.attachments.map { |attachment| attachment_json_builder(attachment.attributes) }
  end

  def build_content_type(file_url)
    return unless file_url
    extname = File.extname(file_url).delete(".")
    "application/#{extname}"
  end

  def attachment_json_builder(attributes)
    {
      content_id: attributes.fetch("content_id", SecureRandom.uuid),
      title: attributes.fetch("title", nil),
      url: attributes.fetch("file_url", nil),
      updated_at: attributes.fetch("updated_at", nil),
      created_at: attributes.fetch("created_at", nil),
      content_type: build_content_type(attributes.fetch("file_url", nil))
    }
  end

  def update_type
    return @update_type if @update_type.present?
    # The first edition to be sent to the publishing-api must always be sent as
    # a major update
    return "major" unless document.has_ever_been_published?

    document.minor_update? ? "minor" : "major"
  end

  def rendered_document_attributes
    @rendered_document_attributes ||= document_renderer.call(document).attributes
  end

  def organisation_info
    {
      title: organisation["title"],
      abbreviation: organisation["details"]["abbreviation"],
      web_url: organisation["web_url"],
    }
  end
end
