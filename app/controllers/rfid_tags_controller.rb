class RfidTagsController < ApplicationController
  before_action :set_user, only: [:create, :destroy]
  before_action :set_rfid_tag, only: [:edit, :update]

  def index
    @rfid_tags = RfidTag.includes(:user, :tracking_events).order(:tag_id)
  end

  def create
    @rfid_tag = @user.rfid_tags.new(tag_id: params[:rfid_tag][:tag_id])

    if @rfid_tag.save
      redirect_to @user, notice: "RFID tag added successfully."
    else
      flash[:alert] = "Error adding RFID tag."
      redirect_to @user
    end
  end

  def destroy
    @rfid_tag = @user.rfid_tags.find(params[:id])
    @rfid_tag.update(user_id: nil)
    redirect_to @user, notice: "RFID tag removed successfully."
  end

  def edit
    @users = User.order(:username) # List users for selection
  end

  def update
    # If "Remove User" was checked, set user_id to nil
    if params[:rfid_tag][:remove_user] == "1"
      @rfid_tag.update(user_id: nil)
    else
      @rfid_tag.update(rfid_tag_params)
    end

    if @rfid_tag.save
      redirect_to rfid_tags_path, notice: "RFID tag updated successfully."
    else
      flash.now[:alert] = "Error updating RFID tag."
      render :edit
    end
  end

  private

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_rfid_tag
    @rfid_tag = RfidTag.find(params[:id])
  end

  def rfid_tag_params
    params.require(:rfid_tag).permit(:tag_id, :user_id)
  end
end
