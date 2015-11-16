class Document
  include ActiveModel::Model

  attr_accessor :content_id, :title, :summary, :body, :format_specific_fields, :state, :bulk_published

  def initialize(params = {}, format_specific_fields = [])
    @title = params.fetch(:title, nil)
    @summary = params.fetch(:summary, nil)
    @body = params.fetch(:body, nil)
    @format_specific_fields = format_specific_fields

    format_specific_fields.each do |field|
      public_send(:"#{field.to_s}=", params.fetch(field, nil))
    end
  end

  def base_path
    "#{public_path}/#{title.parameterize}"
  end

  def content_id
    @content_id || SecureRandom.uuid
  end

  def format
    "document"
  end

  def phase
    "live"
  end

  def published?
    false
  end

  def organisations
    []
  end

  def users
    content_item.users || []
  end

  def facet_options(facet)
    finder_schema.options_for(facet)
  end

private

  def finder_schema
    @finder_schema ||= FinderSchema.new(format.pluralize)
  end

end