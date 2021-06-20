class Api::V1::UsersController < Api::V1::ApplicationController
    
    before_action :authorized, only: [:auto_login]

    #User Register
    def register
      @user = User.new(user_params)
      if @user.save
          @token = issue_token(@user)
          render json: { user: @user, token: @token, message: "User Created Successfully"}, status: :created
      else
          render json: { error: "Errors in Your Input, Failed to Create User", message: @user.errors}, status: 500
      end
    end
    
    #User Login
    def login
      @user = User.find_by(email: params[:email])
      if @user && @user.valid_password(params[:password], @user.password_digest)
        token = issue_token(@user)
        render json: {token: token, message: "Login Successfully"}, status: :accepted
      else
        render json: {error: "Invalid Email or Password",}, status: 401
      end
    end


    #Auto Login with Token Only
    def auto_login
      render json: @user, status: :ok
    end

  private
    #User Params Allow for User
    def user_params
      params.permit(:name, :email, :password)
    end
end