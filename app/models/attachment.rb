class Attachment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :title
  field :filename
  field :file_id, type: String
  field :file_url, type: String

  embedded_in :specialist_document_edition

  before_save :upload_file, if: :file_has_changed?

  def to_param
    id
  end

  def snippet
    "[InlineAttachment:#{filename}]"
  end

  def file
    raise ApiClientNotPresent unless AttachmentApi.client
    unless file_id.nil?
      @attachments ||= {}
      @attachments[field] ||= AttachmentApi.client.asset(file_id)
    end
  end

  def file=(file)
    @file_has_changed = true
    @uploaded_file = file
  end

  def file_has_changed?
    @file_has_changed
  end

  def upload_file
    raise ApiClientNotPresent unless AttachmentApi.client
    begin
      if file_id.nil?
        response = AttachmentApi.client.create_asset(file: @uploaded_file)
        self.file_id = response["id"].split("/").last
      else
        response = AttachmentApi.client.update_asset(file_id, file: @uploaded_file)
      end
      self.file_url = response["file_url"]
    rescue StandardError
      errors.add(:file_id, "could not be uploaded")
    end
  end

  private :upload_file

  class ::ApiClientNotPresent < StandardError; end
end
