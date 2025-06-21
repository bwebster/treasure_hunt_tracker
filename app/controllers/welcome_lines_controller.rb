class WelcomeLinesController < ApplicationController
  before_action :set_welcome_line, only: %i[show edit update destroy]

  def index
    @welcome_lines = WelcomeLine.all
  end

  def show; end

  def new
    @welcome_line = WelcomeLine.new
  end

  def edit; end

  # POST /welcome_lines or /welcome_lines.json
  def create
    @welcome_line = WelcomeLine.new(welcome_line_params)

    if @welcome_line.save
      redirect_to welcome_lines_path, notice: "Welcome line was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /welcome_lines/1 or /welcome_lines/1.json
  def update
    if @welcome_line.update(welcome_line_params)
      redirect_to welcome_lines_path, notice: "Welcome line was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /welcome_lines/1 or /welcome_lines/1.json
  def destroy
    @welcome_line.destroy!

    redirect_to welcome_lines_path, status: :see_other, notice: "Welcome line was successfully destroyed."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_welcome_line
    @welcome_line = WelcomeLine.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def welcome_line_params
    params.expect(welcome_line: [:text])
  end
end
