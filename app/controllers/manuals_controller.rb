class ManualsController < ApplicationController

  def index
    if current_user.gds_editor?
      @manuals = Manual.all
    else
      @manuals = Manual.where(organisation_content_id: current_user.organisation_content_id)
    end
  end

  def show
    begin
      @manual = Manual.find(content_id: params[:content_id])
    rescue Manual::RecordNotFound => e
      flash[:danger] = "Manual not found"
      redirect_to manuals_path

      Airbrake.notify(e)
    end
  end

  def new
    @manual = Manual.new
  end

  def edit
    @manual = Manual.find(content_id: params[:content_id])
  end

  def update
    @manual = Manual.find(content_id: params[:content_id])

    manual_content = params["manual"]

    @manual.title = manual_content["title"]
    @manual.summary = manual_content["summary"]
    @manual.body = manual_content["body"]

    if @manual.save
      flash[:success] = "#{@manual.title} has been updated"
      redirect_to manual_path(@manual.content_id)
    else
      flash.now[:danger] = "There was an error updating #{@manual.title}. Please try again later."
      render :edit
    end
  end

  def create
    @manual = Manual.new(params["manual"])

    if @manual.save
      flash[:success] = "Created #{@manual.title}"
      redirect_to manual_path(@manual.content_id)
    else
      flash.now[:danger] = "There was an error creating #{@manual.title}. Please try again later."
      render :new
    end
  end
end
