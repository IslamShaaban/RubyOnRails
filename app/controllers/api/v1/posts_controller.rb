class Api::V1::PostsController < Api::V1::ApplicationController
    
    before_action :authorized
    
    # Get All Posts of Users
    def index
      @posts = Post.all
      if @posts.blank?
        render json: {message: "Posts List is Empty"}, status: :not_found
      else
        @postsData = @posts.to_json(:include => [:user => {:only => [:name]}, :tags => {:only => [:tags]}, :comments => {:only => [:body]}])
        render :json => {posts: JSON.parse(@postsData)}, :status => 200
      end
    end
  
    # Get Specified Post
    def show
      @post = Post.where(id: params[:id]).first
      if @post.blank?
        render json: {message: "Post Not Found"}, :status => 404
      else
        @postData = @post.to_json(:include => [:user => {:only => [:name]}, :tags => {:only => [:tags]}, :comments => {:only => [:body]}])
        render :json => { post: JSON.parse(@postData) }, :status => 200
      end
    end

    # Create New Post
    def create
      if !params[:tags].present? || params[:tags].blank? 
        render json: {message: "Please, Add Tags for Your Post in tags{} object"}, status: :bad_request
      else
        @post = Post.new(post_params.except(:tags))
        @post.user_id = current_user.id
        eval(params[:tags]).each do |tag|
          @tag = @post.tags.new(tags: tag, post_id: @post.id)
          @tag.save
        end
        if @post.save
            @postData = @post.to_json(:include => [:tags => {:only => [:tags]}])
            render json: {post: JSON.parse(@postData), message: "Post Created Successfully"}, status: :created
        else
            render json: {message: "Sorry, Something Wrong has Happend", errors: @post.errors}, status: :bad_request
        end
      end
    end


    # Update Specified Post
    def update
      @post = Post.where(id: params[:id]).first
      if @post
        if @post.user_id == current_user.id
          if @post.update(post_params.except(:tags))
            if params.has_key?(:tags)
              @tags = Tag.where(post_id: @post.id)
              @tags.delete_all
              eval(params[:tags]).each do |tag|
                @tag = @post.tags.new(tags: tag, post_id: @post.id)
                @tag.save
              end
            end
            @postData = @post.to_json(:include => [:tags => {:only => [:tags]}])
            render json: {post: JSON.parse(@postData), message: "Your Post Updated Successfully"}, status: :ok
          else
            render json: {message: "Sorry, Something Wrong has Happend", errors: @post.errors}, status: :bad_request
          end
        else
          render json: {error: "Sorry, You Don't Have Permission to Update This Post"}, status: :unauthorized
        end
      else
        render json: {message: "Post Not Found"}, status: :not_found
      end
    end

    # Delete Specified Post
    def destroy
      @post = Post.where(id: params[:id]).first
      if @post
        if @post.user_id == current_user.id
          @post.destroy
          render json: {message: "Your Post Deleted Successfully"}, status: :accepted
        else
          render json: {error: "Sorry, You Don't Have Permission to Delete This Post"}, status: :unauthorized
        end
      else
        render json: {message: "Post Not Found"}, status: :not_found
      end
    end

    # Delete All Posts of Current User    
    def destroyAll
      @posts = Post.where(user_id: current_user.id)
      if !@posts.blank?
        @posts.delete_all
        render json: {message: "All Your Posts Deleted Successfully"}, status: :ok
      else
        render json: {message: "You Don't Have any Posts Yet!"}, status: :not_found
      end
    end

    private
      # Only allow a list of trusted parameters through.
      def post_params
        params.permit(:id, :title, :body, :tags)
      end
end