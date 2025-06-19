class UsersController < AdminController
  PAGE_SIZE = ENV.fetch("USERS_PER_PAGE", 20).to_i

  before_action :set_user, only: [:edit, :update, :destroy]

  def index
    @users = User.all
                 .order(**sorting(:username))
                 .page(params[:page])
                 .per(PAGE_SIZE)

  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to users_path, notice: "User created successfully."
    else
      flash.now[:alert] = "Error creating user."
      render :new
    end
  end

  def edit
    @unassigned_rfid_tags = RfidTag.where(user_id: nil).order(:tag_id)
  end

  def update
    if @user.update(user_params)
      # If an RFID tag was selected, associate it with the user
      if params[:user][:rfid_tag_id].present?
        RfidTag.find(params[:user][:rfid_tag_id]).update(user_id: @user.id)
      end

      redirect_to users_path, notice: "User updated successfully."
    else
      flash.now[:alert] = "Error updating user."
      render :edit
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: "User removed."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :first_name, :last_name, :email)
  end
end
