class ArticlesController < ApplicationController
  include StrongParams

  before_action :set_article, only: [:show, :edit, :update, :destroy, :publish, :unpublish]

  load_and_authorize_resource

  respond_to :html, :json

  def new
    @article = Article.new
    @article.audios.build
    @categories = Category.all
  end

  def index
    if params[:q].blank?
      @articles = Article.includes(:category, :language).page(params[:page]).per(20)
    else
      @articles = Article.includes(:category, :language).article_search(params[:q]).page(params[:page]).per(20)
    end
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      @categories = Category.all
      render 'new'
    end
  end

  def edit
    @categories = Category.all
  end

  def destroy
    @article.destroy

    redirect_to articles_path
  end

  def show
  end

  def update
    if @article.update(article_params)
      redirect_to @article
    else
      @categories = Category.all
      render 'edit'
    end
  end

  def publish
    respond_with(@article) do |format|
      if @article.published!
        flash[:notice] = "The article has been published."

        format.html { redirect_to article_path(@article) }
        format.json { render json: @article, location: article_path(@article) }
      else
        flash[:error] = "Failed to publish the article, please try again."

        format.html { redirect_to article_path(@article) }
        format.json { render json: @article.errors.to_hash(true), status: :unprocessable_entity }
      end
    end
  end

  def unpublish
    respond_with(@article) do |format|
      if @article.draft!
        flash[:notice] = "The article has been drafted."

        format.html { redirect_to article_path(@article) }
        format.json { render json: @article, location: article_path(@article) }
      else
        flash[:error] = "Failed to draft the article, please try again."

        format.html { redirect_to article_path(@article) }
        format.json { render json: @article.errors.to_hash(true), status: :unprocessable_entity }
      end
    end
  end

  private
  def set_article
    @article = Article.includes(:category, :language, :audios).find(params[:id])
  end
end
