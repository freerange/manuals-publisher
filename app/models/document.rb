class Document
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :content_id, :base_path, :title, :summary, :body, :format_specific_fields, :public_updated_at, :state, :bulk_published, :publication_state, :update_type, :change_note, :change_history

  validates :title, presence: true
  validates :summary, presence: true
  validates :body, presence: true, safe_html: true
  validates :change_note, presence: true, if: :major_update?
  validates :update_type, presence: true

  COMMON_FIELDS = [
    :title,
    :summary,
    :body,
    :publication_state,
    :public_updated_at,
  ]

  def initialize(params = {}, format_specific_fields = [])
    @content_id = params.fetch(:content_id, SecureRandom.uuid)
    @format_specific_fields = format_specific_fields

    (COMMON_FIELDS + format_specific_fields).each do |field|
      public_send(:"#{field.to_s}=", params.fetch(field, nil))
    end
  end

  def base_path
    @base_path ||= "#{public_path}/#{title.parameterize}"
  end

  def format
    "document"
  end

  def phase
    "live"
  end

  def public_path
    raise NoMethodError
  end

  def live?
    publication_state == "live"
  end

  def draft?
    publication_state == "draft"
  end

  def change_notes
    (change_history + [change_note]).compact
  end

  def major_update?
    update_type == "major"
  end

  def facet_options(facet)
    finder_schema.options_for(facet)
  end

  def organisations
    finder_schema.organisations
  end

  def format_specific_metadata
    format_specific_fields.each_with_object({}) do |f, fields|
      fields[f] = send(f)
    end
  end

  def humanized_attributes
    format_specific_metadata.inject({}) do |attributes, (key, value)|
      humanized_name = finder_schema.humanized_facet_name(key) { key }
      humanized_value = finder_schema.humanized_facet_value(key, value) { value }

      attributes.merge(humanized_name => humanized_value)
    end
  end


  def self.from_publishing_api(payload)
    document = self.new(
      {
        content_id: payload.content_id,
        title: payload.title,
        summary: payload.description,
        body: payload.details.body,
        publication_state: payload.publication_state,
        public_updated_at: payload.public_updated_at
      }
    )

    document.base_path = payload.base_path
    document.change_history = payload.details.change_history

    document.format_specific_fields.each do |field|
      document.public_send(:"#{field.to_s}=", payload.details.metadata.send(field))
    end

    document
  end

  def public_updated_at
    @public_updated_at ||= Time.zone.now
  end

  def public_updated_at=(timestamp)
    @public_updated_at = Time.parse(timestamp) unless timestamp.nil?
  end

private

  def finder_schema
    @finder_schema ||= FinderSchema.new(format.pluralize)
  end

end
