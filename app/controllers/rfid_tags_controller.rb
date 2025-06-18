class RfidTagsController < AdminController
  PAGE_SIZE = ENV.fetch("RFID_TAGS_PER_PAGE", 30).to_i

  before_action :set_user, only: [:create, :destroy]
  before_action :set_rfid_tag, only: [:edit, :update]

  rescue_from ActiveRecord::RecordNotFound do
    flash[:alert] = "RFID Tag Not Found"
    redirect_to rfid_tags_path
  end

  def index
    @rfid_tags = RfidTag
                   .includes(:user, :tracking_events)
                   .order(:tag_id)
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
  end

  def update
    update_params = rfid_tag_params

    username = params[:rfid_tag][:new_username]
    if username.present?
      begin
        user = User.create!(username: username)
      rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
        flash.now[:alert] = "Username #{username} already taken!"

        @users = get_all_users
        @scores = Score.where(rfid_tag: @rfid_tag).order(created_at: :asc)

        render :edit, status: :unprocessable_entity
        return
      end

      update_params[:user_id] = user.id
    end

    # Regenerate a label if needed
    update_params[:label] = RfidTag.generate_label if update_params[:label].blank?

    @rfid_tag.assign_attributes(update_params)

    if @rfid_tag.save
      @users = get_all_users
      if params[:registration_mode] == "true"
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

  def rfid_tag_params
    params.require(:rfid_tag).permit(:user_id, :label)
  end
end
