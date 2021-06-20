class Api::V1::CommentsController < Api::V1::ApplicationController
    
    before_action :authorized
  
    # GET All Comments
    def index
      @comments = Comment.where(post_id: params[:post_id])
      if !@comments.blank?
        render :json => {comments: @comments}, :status => 200
      else
        render json: {message: "No Comments Found on This Post Yet!"}, :status => 404
      end
    end
  
    # GET Specified Comment
    def show
      @comment = Comment.where(post_id: params[:post_id], id: params[:id]).first
      if @comment.blank?
        render json: {message: "No Comment Found Yet!"}, :status => 404
      else
        render :json => {comment: @comment}, :status => 200
      end
    end
  
    # Create New Comment
    def create
      @post = Post.where(:id => params[:post_id])
      if !@post.blank?
        @comment = Comment.new(comment_params)
        @comment.user_id = current_user.id
        if @comment.save
          render json: { comment: @comment, message: "Comment Created Successfully" }, status: :created
        else
          render json: {message: "Something Wrong has Happend", Errors: @comment.errors}, status: :bad_request
        end
      else
        render json: {message: "Post Not Found"}, status: :not_found
      end
    end
  
    # Update Specified Comment
    def update
      @post = Post.where(:id => params[:post_id])
      if !@post.blank?
        @comment = Comment.where(post_id: params[:post_id], id: params[:id]).first
        if @comment
          if @comment.user_id == current_user.id
            if @comment.update(comment_params)
              render json: { comment: @comment, message: "Comment Updated Successfully" }, status: :ok
            else
              render json: { Errors: @comment.errors, message: "Something Wrong has Happend" }, status: :bad_request
            end
          else
            render json: {error: "Sorry, You Don't Have Permission to Delete This Post"}, status: :unauthorized
          end
        else
          render json: {message: "No Comment Found"}, status: :not_found
        end
      else
        render json: {message: "Post Not Found"}, status: :bad_request
      end
    end
  
    # Delete Specified Comment for Current User
    def destroy
      @comment = Comment.where(post_id: params[:post_id], id: params[:id]).first
      if @comment
        if @comment.user_id == current_user.id
          @comment.destroy
          render json: {message: "Your Comment Deleted Successfully"}, status: :accepted
        else
          render json: {error: "Sorry, You Don't Have Permission to Delete This Post"}, status: :unauthorized
        end
      else
        render json: {message: "No Comment Found"}, status: :not_found
      end
    end

    # Delete All Your Comments on Specified Post
    def destroyAll
      @comment = Comment.where(post_id: params[:post_id], user_id: current_user.id)
      if !@comment.blank?
        @comment.delete_all
        render json: {message: "All Comments on This Post Deleted Successfully"}, status: :ok
      else
        render json: {message: "You Don't Have Comments Yet!"}, status: :not_found
      end
    end

    private
      # Only allow a list of trusted parameters through.
      def comment_params
        params.permit(:post_id, :body)
      end
end