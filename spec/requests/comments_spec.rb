require 'rails_helper'

def authenticated_header(user)
    token = JWT.encode({user_id: user.id}, nil, 'HS256')
    { 'Authorization': "#{token}" }
end

describe 'Comments API', type: :request do
    
    # Create User and Post in System
    before do
        @user = User.create(name: 'WebOps', email: 'WebOps@WebOps.com', password: 'WebOps_123')
        @post = Post.create(title: 'Title of Post', body: 'Body of Post', user_id: @user.id)
    end
    
    # GET Comments API
    describe 'GET Comments API', type: :request do

        context 'when the request to Get All Comments on Specified Post without Authorization Token' do
            it 'returns Please Login' do
                get "/api/v1/posts/#{@post.id}/comments"
                expect(response).to have_http_status(401)
            end
        end
        
        context 'when the request to Get All Comments with Authorization Token and Comments List Not Empty' do
            it 'returns all Comments on Specified Post' do
                @comment = Comment.create(body: 'Body of Comment', post_id: @post.id, user_id: @user.id)
                get "/api/v1/posts/#{@post.id}/comments", headers: authenticated_header(@user)
                expect(response).to have_http_status(200)
            end
        end

        context 'when the request to Get All Comments with Authorization Token and Comments List is Empty' do
            it 'returns message of no comments found' do
                @comment = Comment.create(body: 'Body of Comment', post_id: @post.id, user_id: @user.id)
                @comments = Comment.where(post_id: @post.id)
                @comments.delete_all
                get "/api/v1/posts/#{@post.id}/comments/", headers: authenticated_header(@user)
                expect(response).to have_http_status(404)
            end
        end
    end    

    # GET Comment API
    describe 'GET Comment API', type: :request do
        
        before do
            @comment = Comment.create(body: 'Body of Post', post_id: @post.id, user_id: @user.id)
        end

        context 'when the request to Get Specified Comment without Authorization Token' do
            it 'returns Please Login' do
                get "/api/v1/posts/#{@post.id}/comments/#{@comment.id}/"
                expect(response).to have_http_status(401)
            end
        end
        
        context 'when the request to Get Specified Comment with Authorization Token and Comment is Found' do
            it 'returns specified Comment on specified Post' do
                get "/api/v1/posts/#{@post.id}/comments/#{@comment.id}/", headers: authenticated_header(@user)
                expect(response).to have_http_status(200)
            end
        end

        context 'when the request to Get Specified Comment with Authorization Token and Post not Found or Comment Not Found' do
            it 'returns message of no post found' do
                @comment.destroy
                get "/api/v1/posts/#{@post.id}/comments/#{@comment.id}/", headers: authenticated_header(@user)
                expect(response).to have_http_status(404)
            end
        end
    end

    # POST Comment API
    describe 'POST Post API', type: :request do

        context 'when the request to POST Specified Comment on Specified Post without Authorization Token' do
            it 'returns Please Login' do
                post "/api/v1/posts/#{@post.id}/comments", params: {body: 'Body of Post'}
                expect(response).to have_http_status(401)
            end
        end
        
        context 'when the request to POST Specified Comment on Specified Post with Authorization Token' do
            it 'returns specified Comment' do
                post "/api/v1/posts/#{@post.id}/comments", params: {body: 'Body of Post'}, headers: authenticated_header(@user)
                @comment = Comment.create(body: request.params[:body], post_id: @post.id, user_id: @user.id)
                expect(response).to have_http_status(201)
            end
        end

        context 'when the request to POST Specified Comment with Authorization Token and Post not Found' do
            it 'returns message of post not found' do
                @post.destroy
                post "/api/v1/posts/#{@post.id}/comments", params: {body: 'Body of Post'}, headers: authenticated_header(@user)
                expect(response).to have_http_status(404)
            end
        end
    end 
    
    # Update Post API
    describe 'PUT Comment API', type: :request do
        
        before do
            @comment = Comment.create(body: 'Body of Post', post_id: @post.id, user_id: @user.id)
        end

        context 'when the request to PUT Specified Post without Authorization Token' do
            it 'returns Please Login' do
                put "/api/v1/posts/#{@post.id}/comments/#{@comment.id}", params: {body: 'Edit of Comment'}
                expect(response).to have_http_status(401)
            end
        end
        
        context 'when the request to PUT Specified Comment on Specified Post with Authorization Token' do
            it 'returns specified comment after update' do
                put "/api/v1/posts/#{@post.id}/comments/#{@comment.id}", params: {body: 'Edit of Comment'}, headers: authenticated_header(@user)
                @comment.reload[:params]
                expect(response).to have_http_status(200)
            end
        end

        context 'when the request to PUT Specified Comment on Specified Post with Authorization Token and Post not Found or Comment not Found' do
            it 'returns message of post or comment not found' do
                @comment.destroy
                put "/api/v1/posts/#{@post.id}/comments/#{@comment.id}", params: {body: 'Body of Post', title: 'Title of Post'}, headers: authenticated_header(@user)
                expect(response).to have_http_status(404)
            end
        end
    end 

    # Delete Post API
    describe 'DELETE Post API', type: :request do
        
        before do
            @comment = Comment.create(body: 'Body of Post', post_id: @post.id, user_id: @user.id)
        end

        context "when the request to Delete Specified Comment without Authorization Token or Don't have Ownership of this Comment" do
            it 'returns Please Login' do
                delete "/api/v1/posts/#{@post.id}/comments/#{@comment.id}"
                expect(response).to have_http_status(401)
            end
        end
        
        context 'when the request to Delete Specified Comment on Specified Post with Authorization Token and Comment is Found' do
            it 'returns comment deleted successfully' do
                delete "/api/v1/posts/#{@post.id}/comments/#{@comment.id}", headers: authenticated_header(@user)
                expect(response).to have_http_status(202)
            end
        end

        context 'when the request to Delete Specified Comment on Specified Post with Authorization Token and Comment not Found' do
            it 'returns message of no comment found' do
                @comment.destroy
                delete "/api/v1/posts/#{@post.id}/comments/#{@comment.id}", headers: authenticated_header(@user)
                expect(response).to have_http_status(404)
            end
        end

        context "when the request to Delete User's Comments on Specified Post without Authorization Token" do
            it 'returns message Please Login' do
                delete "/api/v1/posts/#{@post.id}/my-comments"
                expect(response).to have_http_status(401)
            end
        end

        context "when the request to Delete User's Comments on Specified Post with Authorization Token and Comments are Found" do
            it 'returns message of comments deleted successfully' do
                delete "/api/v1/posts/#{@post.id}/my-comments", headers: authenticated_header(@user)
                Comment.where(post_id: @post.id, user_id: @user.id)
                Comment.delete_all
                expect(response).to have_http_status(200)
            end
        end

        context "when the request to Delete User's Posts with Authorization Token and Posts not Found" do
            it 'returns message of no comments found or no post found' do
                Comment.where(post_id: @post.id, user_id: @user.id)
                Comment.delete_all
                delete "/api/v1/posts/#{@post.id}/my-comments", headers: authenticated_header(@user)
                expect(response).to have_http_status(404)
            end
        end
    end 
end