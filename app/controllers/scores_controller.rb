class ScoresController < AdminController
  PAGE_SIZE = ENV.fetch("SCORES_PER_PAGE", 30).to_i

  def index
    @scores = Score
                .order(created_at: :asc)
                .page(params[:page])
                .per(PAGE_SIZE)
  end
end
