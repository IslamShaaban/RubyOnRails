require 'rails_helper'

def authenticated_header(user)
    token = JWT.encode({user_id: user.id}, nil, 'HS256')
    { 'Authorization': "#{token}" }
end

describe 'Posts API', type: :request do
    
    # Create User in System
    before do
        @user = User.create(name: 'WebOps', email: 'WebOps@WebOps.com', password: 'WebOps_123')
    end
    
    # GET Posts API
    describe 'GET Posts API', type: :request do
        before do
            @post = Post.create(title: 'Title of Post', body: 'Body of Post', user_id: @user.id)
        end
        
        context 'when the request to Get All Posts without Authorization Token' do
            it 'returns Please Login' do
                get '/api/v1/posts/'
                expect(response).to have_http_status(401)
            end
        end
        
        context 'when the request to Get All Posts with Authorization Token and Posts List Not Empty' do
            it 'returns all posts' do
                @post = Post.create(title: 'Title of Post', body: 'Body of Post', user_id: @user.id)
                get '/api/v1/posts/', headers: authenticated_header(@user)
                expect(response).to have_http_status(200)
            end
        end

        context 'when the request to Get All Posts with Authorization Token and Posts List is Empty' do
            it 'returns message of no posts found' do
                Post.delete_all
                get '/api/v1/posts/', headers: authenticated_header(@user)
                expect(response).to have_http_status(404)
            end
        end
    end    

    # GET Post API
    describe 'GET Post API', type: :request do
        
        before do
            @post = Post.create(title: 'Title of Post', body: 'Body of Post', user_id: @user.id)
        end

        context 'when the request to Get Specified Post without Authorization Token' do
            it 'returns Please Login' do
                get "/api/v1/posts/#{@post.id}"
                expect(response).to have_http_status(401)
            end
        end
        
        context 'when the request to Get Specified Post with Authorization Token and Post is Found' do
            it 'returns specified post' do
                get "/api/v1/posts/#{@post.id}", headers: authenticated_header(@user)
                expect(response).to have_http_status(200)
            end
        end

        context 'when the request to Get Specified Post with Authorization Token and Post not Found' do
            it 'returns message of no post found' do
                @post.destroy
                get "/api/v1/posts/#{@post.id}", headers: authenticated_header(@user)
                expect(response).to have_http_status(404)
            end
        end
    end

    # Post Post API
    describe 'POST Post API', type: :request do

        context 'when the request to POST Specified Post without Authorization Token' do
            it 'returns Please Login' do
                post "/api/v1/posts/"
                expect(response).to have_http_status(401)
            end
        end
        
        context 'when the request to POST Specified Post with Authorization Token' do
            it 'returns specified post' do
                post "/api/v1/posts/", params: {body: 'Body of Post', title: 'Title of Post', tags: "['Physics', 'Science']"}, headers: authenticated_header(@user)
                @post = Post.create(title: request.params[:title], body: request.params[:body])
                eval(request.params[:tags]).each do |tag|
                    @tag = @post.tags.new(tags: tag, post_id: @post.id)
                    @tag.save
                end
                expect(response).to have_http_status(201)
            end
        end

        context 'when the request to POST Specified Post with Authorization Token and tags object not Found' do
            it 'returns message of tags must be found' do
                post "/api/v1/posts/", params: {body: 'Body of Post', title: 'Title of Post'}, headers: authenticated_header(@user)
                expect(response).to have_http_status(400)
            end
        end
    end 
    
    # Update Post API
    describe 'PUT Post API', type: :request do
        
        before do
            @post = Post.create(title: 'Title of Post', body: 'Body of Post', user_id: @user.id)
        end

        context 'when the request to PUT Specified Post without Authorization Token' do
            it 'returns Please Login' do
                put "/api/v1/posts/#{@post.id}"
                expect(response).to have_http_status(401)
            end
        end
        
        context 'when the request to PuT Specified Post with Authorization Token' do
            it 'returns specified post after update' do
                put "/api/v1/posts/#{@post.id}", params: {body: 'isla of Post', title: 'Tisds of Post'}, headers: authenticated_header(@user)
                @post.reload[:params]
                expect(response).to have_http_status(200)
            end
        end

        context 'when the request to PUT Specified Post with Authorization Token and post not Found' do
            it 'returns message of post not found' do
                @post.destroy
                put "/api/v1/posts/#{@post.id}", params: {body: 'Body of Post', title: 'Title of Post'}, headers: authenticated_header(@user)
                expect(response).to have_http_status(404)
            end
        end
    end 

    # Delete Post API
    describe 'DELETE Post API', type: :request do
        
        before do
            @post = Post.create(title: 'Title of Post', body: 'Body of Post', user_id: @user.id)
        end

        context "when the request to Delete Specified Post without Authorization Token or Don't have Ownership of this Post" do
            it 'returns Please Login' do
                delete "/api/v1/posts/#{@post.id}"
                expect(response).to have_http_status(401)
            end
        end
        
        context 'when the request to Delete Specified Post with Authorization Token and Post is Found' do
            it 'returns specified post' do
                delete "/api/v1/posts/#{@post.id}", headers: authenticated_header(@user)
                expect(response).to have_http_status(202)
            end
        end

        context 'when the request to Delete Specified Post with Authorization Token and Post not Found' do
            it 'returns message of no post found' do
                @post.destroy
                delete "/api/v1/posts/#{@post.id}", headers: authenticated_header(@user)
                expect(response).to have_http_status(404)
            end
        end

        context "when the request to Delete User's Posts without Authorization Token" do
            it 'returns message of no post found' do
                delete "/api/v1/my-posts/"
                expect(response).to have_http_status(401)
            end
        end

        context "when the request to Delete User's Posts with Authorization Token and Posts are Found" do
            it 'returns message of no posts found' do
                delete "/api/v1/my-posts/", headers: authenticated_header(@user)
                Post.where(user_id: @user.id)
                Post.delete_all
                expect(response).to have_http_status(200)
            end
        end

        context "when the request to Delete User's Posts with Authorization Token and Posts not Found" do
            it 'returns message of no post found' do
                Post.where(user_id: @user.id)
                Post.delete_all
                delete "/api/v1/my-posts", headers: authenticated_header(@user)
                expect(response).to have_http_status(404)
            end
        end
    end 
end