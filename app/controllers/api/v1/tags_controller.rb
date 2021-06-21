class Api::V1::TagsController < Api::V1::ApplicationController
    
    before_action :authorized

    # Show Tags of Posts
    def show
        @tags = Tag.where(post_id: params[:post_id])
        if @tags.blank?
            render json: {message: "Post Not Found"}, status: :not_found           
        else
            render json: {tags: @tags}, status: :ok            
        end
    end

    # Edit Tags of Post
    def update
        params[:q].split(',').each do |tag|
            @tag = Tag.where(tags: tag, post_id: params[:post_id]).first
            @tag.update(tags: tag)
        end
        render json: {message: "Tags Updated Successfully"}, status: :ok
    end
end