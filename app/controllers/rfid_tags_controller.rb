class RfidTagsController < ApplicationController
  before_action :set_user, only: [:create, :destroy]
  before_action :set_rfid_tag, only: [:edit, :update]

  rescue_from ActiveRecord::RecordNotFound do
    flash[:alert] = "RFID Tag Not Found"
    redirect_to rfid_tags_path
  end

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
    @users = get_all_users
  end

  def update
    # Remove existing user
    if params[:rfid_tag][:remove_user] == "1"
      @rfid_tag.user = nil
    end

    # Create and assign a new user
    username = params[:rfid_tag][:new_username]
    exclude_user_id = false
    if username.present?
      begin
        user = User.create!(username: username)
      rescue ActiveRecord::RecordNotUnique
        flash.now[:alert] = "Username #{username} already taken!"
        render :edit, status: :unprocessable_entity
        return
      end

      @rfid_tag.user = user
      exclude_user_id = true
    end

    update_params = rfid_tag_params(exclude_user_id: exclude_user_id)

    # Regenerate a label if needed
    update_params[:label] = RfidTag.generate_label if update_params[:label].blank?

    @rfid_tag.assign_attributes(update_params)

    if @rfid_tag.save
      @users = get_all_users
      if params[:registration_mode]
        redirect_to register_path, notice: "RFID tag updated successfully."
      else
        redirect_to rfid_tags_path, notice: "RFID tag updated successfully."
      end
    else
      @users = get_all_users
      flash.now[:alert] = "Error updating RFID tag."
      render :edit, status: :unprocessable_entity
    end
  end

  def register
    render "register"
  end

  private

  def get_all_users
    User.order(:username).order(username: :asc)
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  def set_rfid_tag
    @rfid_tag = RfidTag.find(params[:id])
  end

  def rfid_tag_params(exclude_user_id: false)
    if exclude_user_id
      return params.require(:rfid_tag).permit(:label)
    end

    params.require(:rfid_tag).permit(:user_id, :label)
  end
end
