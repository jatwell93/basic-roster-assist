class AwardsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  before_action :set_award_rate, only: [ :edit, :update, :destroy ]

  def index
    @award_rates = AwardRate.includes(:user).order(created_at: :desc)
    @users = User.all.order(:name)
  end

  def new
    @award_rate = AwardRate.new
    @users = User.all.order(:name)
  end

  def create
    @award_rate = AwardRate.new(award_rate_params)

    if @award_rate.save
      redirect_to awards_path, notice: "Award rate was successfully created."
    else
      @users = User.all.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @users = User.all.order(:name)
  end

  def update
    if @award_rate.update(award_rate_params)
      redirect_to awards_path, notice: "Award rate was successfully updated."
    else
      @users = User.all.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @award_rate.destroy
    redirect_to awards_path, notice: "Award rate was successfully deleted."
  end

  def users
    @users = User.includes(:award_rates).order(:name)
    @award_rates = AwardRate.all.order(:award_code, :classification)
  end

  def assign_award
    @user = User.find(params[:user_id])
    @available_awards = AwardRate.where(user_id: nil).order(:award_code, :classification)
    @user_awards = @user.award_rates.order(:award_code, :classification)
  end

  def assign_to_user
    @user = User.find(params[:user_id])
    award_rate = AwardRate.find(params[:award_rate_id])

    # Remove any existing assignment for this user and award type
    existing_assignment = AwardRate.find_by(user_id: @user.id, award_code: award_rate.award_code, classification: award_rate.classification)
    existing_assignment&.update(user_id: nil)

    # Assign the new award rate to the user
    award_rate.update(user_id: @user.id)

    redirect_to assign_award_awards_path(user_id: @user.id), notice: "Award assigned successfully."
  end

  def remove_from_user
    @user = User.find(params[:user_id])
    award_rate = AwardRate.find(params[:award_rate_id])

    # Remove the assignment
    award_rate.update(user_id: nil)

    redirect_to assign_award_awards_path(user_id: @user.id), notice: "Award assignment removed."
  end

  private

  def require_admin
    unless current_user.admin?
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end

  def set_award_rate
    @award_rate = AwardRate.find(params[:id])
  end

  def award_rate_params
    params.require(:award_rate).permit(:award_code, :classification, :rate, :effective_date, :user_id)
  end
end
