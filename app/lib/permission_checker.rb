class PermissionChecker
  GDS_EDITOR_PERMISSION = "gds_editor".freeze
  EDITOR_PERMISSION = "editor".freeze

  def initialize(user)
    @user = user
  end

  def can_edit?(format)
    is_gds_editor? || can_access_format?(format)
  end

  def can_publish?(format)
    is_gds_editor? || is_editor? && can_access_format?(format)
  end

  def can_withdraw?(_format)
    is_gds_editor? || is_editor?
  end

  def is_gds_editor?
    user.has_permission?(GDS_EDITOR_PERMISSION)
  end

private

  attr_reader :user

  def is_editor?
    user.has_permission?(EDITOR_PERMISSION)
  end

  def can_access_format?(format)
    format == "manual"
  end
end
