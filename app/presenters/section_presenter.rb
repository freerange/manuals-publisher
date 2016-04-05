class SectionPresenter
  def initialize(section)
    @section = section
  end

  def to_json
    {
      base_path: @section.base_path,
      title: @section.title,
      description: @section.summary,
      format: "manual_section",
      need_ids: [],
      locale: "en",
      public_updated_at: @section.public_updated_at.to_datetime.rfc3339,
      publishing_app: "specialist-publisher",
      rendering_app: "manuals-frontend",
      details: details,
      routes: [{
      path: @section.base_path,
      type: "exact"
    }],
      update_type: @section.update_type
    }
  end

private

  def details
    {
      body: @section.body,
      manual: {
        base_path: @section.manual.base_path
      },
    }.tap do |details_hash|
      details_hash[:attachments] = attachments if @section.attachments
    end
  end

  def attachments
    @section.attachments.map { |attachment| AttachmentPresenter.new(attachment).to_json }
  end
end
