class ManualsController <  ApplicationController

  def index
    if current_user.gds_editor?
      @manuals = Manual.all
    else
      @manuals = Manual.where(organisation_content_id: current_user.organisation_content_id)
    end
  end

  def show
    @manual = Manual.find(content_id: params[:content_id])
  end

  def new
    @manual = Manual.new
  end

end
