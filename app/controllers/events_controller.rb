# frozen_string_literal: true

class EventsController < AdminController
  before_action :set_event, only: %i[edit update destroy copy_locations]

  def index
    @events = Event.order(:date)
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to events_path, notice: "Event created successfully."
    else
      flash.now[:alert] = "Error creating event."
      render :new
    end
  end

  def edit
    @other_events = Event.where.not(id: @event.id).order(:date)
  end

  def update
    if @event.update(event_params)
      redirect_to events_path, notice: "Event updated successfully."
    else
      flash.now[:alert] = "Error updating event."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: "Event deleted successfully."
  end

  def copy_locations
    copy_params = params.require(:event).permit(:copy_locations_from)
    Event.find(copy_params[:copy_locations_from]).locations.each do |location|
      @event.locations.build(location.attributes.except("id", "event_id", "created_at", "updated_at"))
    end

    if @event.save
      redirect_to edit_event_path(@event), notice: "Locations copied successfully."
    else
      flash.now[:alert] = "Error copying locations."
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :date, :test_event)
  end
end
