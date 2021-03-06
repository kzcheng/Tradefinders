class Api::ReviewController < ApplicationController
  def index
    reviews = Review.all

    unless params[:user_id].to_s.strip.empty?
      reviews = reviews.where(user_id: params[:user_id])
    end

    unless params[:company_id].to_s.strip.empty?
      reviews = reviews.where(company_id: params[:company_id])
    end

    # Get photo and user data
    reviews = reviews.left_outer_joins(:photos).left_outer_joins(:user).select(
      "reviews.*",
      "photos.id as #{:photo_url}",
      "photos.photo_url as #{:photo_url}",
      "users.name as #{:user_name}",
      "users.email as #{:user_email}",
      "users.avatar as #{:user_avatar}",
    )

    # Make the newest review show first
    reviews = reviews.order(created_at: :desc)

    cleanliness_avg, reliability_avg, value_avg, workmanship_avg, total_avg = calculate_avg(reviews)

    render :json => {
      params: params,
      reviews: reviews,
      cleanliness_avg: cleanliness_avg,
      reliability_avg: reliability_avg,
      value_avg: value_avg,
      workmanship_avg: workmanship_avg,
      total_avg: total_avg,
    }
  end

  def show
    # Get photo and user data
    reviews = Review.all.left_outer_joins(:photos).left_outer_joins(:user).select(
      "reviews.*",
      "photos.id as #{:photo_url}",
      "photos.photo_url as #{:photo_url}",
      "users.name as #{:user_name}",
      "users.email as #{:user_email}",
      "users.avatar as #{:user_avatar}",
    )

    review = reviews.find params[:id]
    render :json => {
      review: review,
    }
  end

  def create
    review = Review.create(
      user_id: params[:user_id],
      company_id: params[:company_id],
      cleanliness: params[:cleanliness],
      reliability: params[:reliability],
      value: params[:value],
      workmanship: params[:workmanship],
      comment: params[:comment],
    )
    render :json => {
      new_review: review,
    }
  end

  def destroy
  end

  # def bad_path_name
  #   render :json => {
  #     review: "lel"
  #   }
  # end

  # def reviews_for_company_1
  #   reviews_for_company_1 = Review.find_by(company_id: 1)
  #   render :json => {
  #     review: reviews_for_company_1
  #   }
  # end

  # def given_company
  #   reviews_for_given_company = Review.find_by(company_id: params[:company_id])
  #   render :json => {
  #     review: reviews_for_given_company
  #   }
  # end

  private

  def calculate_avg(reviews)
    cleanliness_avg = 0
    reliability_avg = 0
    value_avg = 0
    workmanship_avg = 0

    # Average Calculations
    unless reviews.empty?
      # Calculating all average scores for individual review categories
      cleanliness_avg = reviews.average(:cleanliness).round(2).to_f
      reliability_avg = reviews.average(:reliability).round(2).to_f
      value_avg = reviews.average(:value).round(2).to_f
      workmanship_avg = reviews.average(:workmanship).round(2).to_f
    end

    # Total average scores sum together
    total_avg = ((cleanliness_avg + reliability_avg + value_avg + workmanship_avg) / 4).to_f

    return cleanliness_avg, reliability_avg, value_avg, workmanship_avg, total_avg
  end
end
