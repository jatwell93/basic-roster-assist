class WorkSectionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_work_section, only: [ :edit, :update, :destroy ]

  def index
    @work_sections = current_user.work_sections.order(:name)
  end

  def new
    @work_section = current_user.work_sections.new
  end

  def create
    @work_section = current_user.work_sections.new(work_section_params)

    if @work_section.save
      redirect_to work_sections_path, notice: "Section created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @work_section.update(work_section_params)
      redirect_to work_sections_path, notice: "Section updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @work_section.destroy
    redirect_to work_sections_path, notice: "Section deleted successfully."
  end

  private

  def set_work_section
    @work_section = current_user.work_sections.find(params[:id])
  end

  def work_section_params
    params.require(:work_section).permit(:name)
  end
end
