class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy]
  before_filter :correct_user,   only: [:edit, :update]
  before_filter :shipping_information, only: [:edit, :update]
  before_filter :billing_information, only: [:edit, :update]

  def new
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Awesome Store!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  helper_method :billing_information
  helper_method :shipping_information

  private
    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_path, notice: "Please sign in."
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) && flash_error unless current_user?(@user)
    end

    def flash_error
      flash[:error] = "You are not logged in as the correct user"
    end

    def shipping_information
      if current_user.shipping_information.nil?
        @shipping_information = ShippingInformation.new
      else
        @shipping_information ||= current_user.shipping_information
      end
    end

    def billing_information
      if current_user.billing_information.nil?
        @billing_information = BillingInformation.new
      else
        @billing_information ||= current_user.billing_information
      end
    end

    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_path, notice: "Please sign in."
      end
    end
end
