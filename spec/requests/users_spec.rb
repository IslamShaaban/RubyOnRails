require 'rails_helper'

def authenticated_header(user)
    token = JWT.encode({user_id: user.id}, nil, 'HS256')
    { 'Authorization': "#{token}" }
end


# Test for /api/v1/register
describe 'POST /api/v1/register' do
    context 'when the request contains all required properties for user' do
        it 'should return the user info' do
            post '/api/v1/register', params: {name: 'WebOps', email: 'WebOps@WebOps.com', password: 'WebOps123'}
            @user  = User.create[:params]
            expect(response).to have_http_status(201)
        end
    end

    context 'when the request contains all required properties for user except password' do
        it 'should return Error Password is Required' do
            post '/api/v1/register', params: {name: 'WebOps', email: 'WebOps@WebOps.com'}
            @user  = User.create[:params]
            expect(response).to have_http_status(500)
        end
    end

    context 'when the request contains all required properties for user except email' do
        it 'should return Error Email is Required' do
            post '/api/v1/register', params: {name: 'WebOps', password: 'WebOps123'}
            @user  = User.create[:params]
            expect(response).to have_http_status(500)
        end
    end

    context 'when the request contains all required properties for user except name' do
        it 'should return Error Name is Required' do
            post '/api/v1/register', params: {email: 'WebOps@WebOps.com', password: 'WebOps123'}
            @user  = User.create[:params]
            expect(response).to have_http_status(500)
        end
    end
end

# Test for /api/v1/login
describe 'POST /api/v1/login' do
    before do
        @user = User.create(name: 'WebOps', email: 'WebOps@WebOps.com', password: 'WebOps_123')
    end
    context 'when the request contains all valid required properties for user' do
        it 'should return the user info' do
            post '/api/v1/login', params: {email: 'webops@webops.com', password: 'WebOps_123'}
            @user = User.find_by(email: request.params[:email])
            @user.valid_password(request.params[:password], @user.password_digest)
            expect(response).to have_http_status(200)
        end
    end

    context 'when the request contains only email without password' do
        it 'should return Error Password or Email' do
            post '/api/v1/login', params: {email: 'WebOps@WebOps.com'}
            expect(response).to have_http_status(403)
        end
    end

    context 'when the request contains only password' do
        it 'should return Error Password or Email' do
            post '/api/v1/login', params: {password: 'WebOps123'}
            expect(response).to have_http_status(403)
        end
    end
end

# Test for /api/v1/auto_login
describe 'GET /api/v1/auto_login' do
    
    before do
        @user = User.create(name: 'WebOps', email: 'WebOps@WebOps.com', password: 'WebOps_123')
    end

    context 'when the request without Authentication Token' do
        it 'should return Please Login' do
            get '/api/v1/auto_login'
            expect(response).to have_http_status(401)
        end
    end

    context 'when the request contains Authentication Token' do
        it 'should return User Info' do
            get '/api/v1/auto_login', headers: authenticated_header(@user)
            expect(response).to have_http_status(200)
        end
    end
end