class UsersController < ApplicationController
  
  # GET /register
  def register
    @user = User.new
    respond_to do |format|
      format.html  {render template: "users/register"}
    end
  end

  #Post /register
  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        session[:user_id] = @user.id
        format.html { render :login, notice: "User was successfully created, Please Login" }
      else
        format.html { render :register, notice: "User info Not Continued" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  #Get /login
  def login
    respond_to do |format|
      format.html {render(:template => "users/login")}
    end
  end

  #Post /login
  def check
    @user = User.find(user_params)
    respond_to do |format|
      if @user
        session[:user_id] = @user.id
        format.html { redirect_to @user, notice: "User was successfully created." }
      else
        format.html { render :register, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:username, :email, :password, :password_confirmation)
    end
end