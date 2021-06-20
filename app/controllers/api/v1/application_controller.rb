class Api::V1::ApplicationController < ActionController::API
    
    before_action :authorized

    # Create Token for User
    def issue_token(user)
        JWT.encode({user_id: user.id}, nil, 'HS256')
    end
    
    # Decoded User Token to Check User Info
    def decoded_token
        begin
            JWT.decode(token, nil, false)
        rescue JWT::DecodeError
            [{error: "Invalid Token"}]
        end
    end

    # Check Token in Request Header
    def token
        request.headers['Authorization']
    end
    
    # Get User ID from This Token
    def user_id
        decoded_token.first['user_id']
    end
    
    # Find User by Decoded Token and Check User ID
    def current_user
        @user ||= User.find_by(id: user_id)
    end
    
    # Check if Current User is Logged In or Not
    def logged_in?
        !!current_user
    end    

    # Check User is Authorized or Not
    def authorized
        render json: { message: 'Please Login' }, status: :unauthorized unless logged_in?
    end
end