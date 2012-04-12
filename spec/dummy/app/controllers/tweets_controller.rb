require "user"
class TweetsController < ApplicationController
  before_filter :find_user
  before_filter :find_tweet, except: [:index, :new, :create]
  crudable_filter parent: "user"

  # GET /:user_id/tweets
  # GET /:user_id/tweets.json
  def index
    @tweets = @user.tweets.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @tweets }
    end
  end

  # GET /:user_id/tweets/1
  # GET /:user_id/tweets/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @tweet }
    end
  end

  # GET /:user_id/tweets/new
  # GET /:user_id/tweets/new.json
  def new
    @tweet = @user.tweets.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @tweet }
    end
  end

  # GET /:user_id/tweets/1/edit
  def edit
  end

  # POST /:user_id/tweets
  # POST /:user_id/tweets.json
  def create
    @tweet = @user.tweets.build(params[:tweet])

    respond_to do |format|
      if @tweet.save
        format.html { redirect_to user_tweet_path(@user, @tweet), notice: 'Tweet was successfully created.' }
        format.json { render json: @tweet, status: :created, location: user_tweet_path(@user, @tweet) }
      else
        format.html { render action: "new" }
        format.json { render json: @tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /:user_id/tweets/1
  # PUT /:user_id/tweets/1.json
  def update
    respond_to do |format|
      if @tweet.update_attributes(params[:tweet])
        format.html { redirect_to user_tweet_path(@user, @tweet), notice: 'Tweet was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @tweet.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /:user_id/tweets/1
  # DELETE /:user_id/tweets/1.json
  def destroy
    @tweet.destroy

    respond_to do |format|
      format.html { redirect_to tweets_url }
      format.json { head :no_content }
    end
  end

  def find_user
    @user = User.find_by_name(params[:user_name])
  end
  def find_tweet
    @tweet = Tweet.find(params[:id])
  end
end
