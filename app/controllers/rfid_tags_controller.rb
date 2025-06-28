# frozen_string_literal: true

class RfidTagsController < AdminController
  PAGE_SIZE = ENV.fetch("RFID_TAGS_PER_PAGE", 30).to_i
  UUID_REGEX = /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i

  before_action :set_user, only: %i[create destroy]
  before_action :set_rfid_tag, only: %i[edit update]

  rescue_from ActiveRecord::RecordNotFound do
    flash[:alert] = "RFID Tag Not Found"
    redirect_to rfid_tags_path
  end

  def index
    @rfid_tags = RfidTag
                 .includes(:user, :tracking_events)
                 .order(**sorting(:label))
                 .page(params[:page])
                 .per(PAGE_SIZE)
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
    redirect_to edit_user_path(@user), notice: "RFID tag removed successfully."
  end

  def edit
    @users = get_all_users
    @scores = Score.where(rfid_tag: @rfid_tag).order(created_at: :asc)
    @user_id = params[:user_id]
    @location_id = params[:location_id]
  end

  def update
    # For registration - we need to proxy along these params
    user_id = params[:user_id]
    location_id = params[:location_id]

    update_params = rfid_tag_params
    registration_mode = update_params[:registration_mode] == "true"

    # Regenerate a label if needed
    update_params[:label] = RfidTag.generate_label if update_params[:label].blank?

    # If it's not a number, treat it as a new username
    user_id_or_name = update_params[:user_id]
    if user_id_or_name.present? && !uuid?(user_id_or_name)
      new_user = User.find_or_create_by(username: user_id_or_name)
      update_params[:user_id] = new_user.id
    end

    if @rfid_tag.update(update_params)
      if registration_mode
        user_id = @rfid_tag.user&.id if @rfid_tag.user.previous_changes.key?(:username)

        redirect_to register_path(user_id:, location_id:), notice: "RFID tag updated successfully."
      else
        redirect_to rfid_tags_path, notice: "RFID tag updated successfully."
      end
    elsif registration_mode
      # Go back to registration with errors
      redirect_to register_path(user_id:, location_id:)
    else
      # Go back to edit with errors
      @users = get_all_users
      @scores = Score.where(rfid_tag: @rfid_tag).order(created_at: :asc)
      render :edit, status: :unprocessable_entity
    end
  end

  def register
    @welcome_lines = WelcomeLine.all
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

  def rfid_tag_params
    params.require(:rfid_tag).permit(:label, :user_id, user_attributes: [:username])
  end

  def uuid?(value)
    value.to_s.match?(UUID_REGEX)
  end
end
