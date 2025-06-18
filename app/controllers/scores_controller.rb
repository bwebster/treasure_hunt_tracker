class ScoresController < AdminController
  def index
    @scores = Score.order(created_at: :asc).page(params[:page]).per(30)
  end
end
