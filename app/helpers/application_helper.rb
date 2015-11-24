module ApplicationHelper

  def bootstrap_class_for(flash_type)
    case flash_type
    when :success
      "alert-success" # Green
    when :error
      "alert-danger" # Red
    when :alert
      "alert-warning" # Yellow
    when :notice
      "alert-info" # Blue
    else
      flash_type.to_s
    end
  end

  def content_preview_url(document)
    Plek.current.find("draft-origin") + document.base_path
  end

  def published_document_path(document)
    Plek.current.find("website-root") + document.base_path
  end
end
