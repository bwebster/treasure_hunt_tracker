# frozen_string_literal: true

class LocationsController < AdminController
  before_action :set_event
  before_action :set_location, only: %i[edit update destroy]

  def new
    @location = @event.locations.new
  end

  def create
    @location = @event.locations.new(location_params)
    if @location.save
      redirect_to edit_event_path(@event), notice: "Location added successfully."
    else
      flash.now[:alert] = "Error adding location."
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @location.update(location_params)
      redirect_to edit_event_path(@event), notice: "Location updated successfully."
    else
      flash.now[:alert] = "Error updating location."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @location.destroy
    redirect_to edit_event_path(@event), notice: "Location removed."
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_location
    @location = @event.locations.find(params[:id])
  end

  def location_params
    params.require(:location).permit(:name, :number, :registration)
  end
end
