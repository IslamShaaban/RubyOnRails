require 'sidekiq'

class DeletePostWorker
  include Sidekiq::Worker
  def perform
    @posts = Post.where('updated_at >= ?', 24.hours.ago )
    if @posts.blank?
      puts "Posts List is Empty"
    else
      @posts.delete_all
      puts "Posts Deleted Successfully"
    end
  end
end