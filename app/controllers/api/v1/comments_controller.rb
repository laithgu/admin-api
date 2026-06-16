class Api::V1::CommentsController < ApplicationController
  # 获取某部电影的评论
  # GET /api/v1/movies/:movie_id/comments
  def index
    movie = Movie.find(params[:movie_id])
    comments = movie.comments.order(created_at: :desc)

    render json: { data: comments }
  rescue ActiveRecord::RecordNotFound
    render :json => { error: "电影不存在" }, status: :not_found
  end

  # 创建评论
  # POST /api/v1/movies/:movie_id/comments
  def create
    movie = Movie.find(params[:movie_id])
    comment = movie.comments.new(comment_params)

    if comment.save
      render json: { data: comment }, status: :created
    else
      render :json => { error: comment.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render :json => { error: "电影不存在" }, status: :not_found
  end

  # 删除评论
  # DELETE /api/v1/comments/:id
  def destroy
    comment = Comment.find(params[:id])
    comment.destroy!
    render :json => { message: "删除成功" }
  rescue ActiveRecord::RecordNotFound
    render :json => { err: "评论不存在" }, status: :not_found
  end

  private
  def comment_params
    params.require(:comment).permit(:content, :author)
  end
end