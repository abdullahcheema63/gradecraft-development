class BadgesController < ApplicationController

  before_filter :ensure_staff?, :only=>[:new,:edit,:create,:update,:destroy]

  def index
    @title = "View All Badges"
    @badge_set = BadgeSet.find(params[:badge_set_id])
    @badges = @badge_sets.badges.where(params[:badge_set_id])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @badges }
    end
  end

  def show
    @badge_set = BadgeSet.find(params[:badge_set_id])
    @title = "View Badge"
    @badge = Badge.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @badge }
    end
  end

  def new
    @title = "Create a New Badge"
    @badge = Badge.new
    @badge_set = BadgeSet.find(params[:badge_set_id])
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @badge }
    end
  end

  def edit
    @title = "Edit Badge"
    @badge_set = BadgeSet.find(params[:badge_set_id])
    @badge = Badge.find(params[:id])
  end

  def create
    @badge_set = BadgeSet.find(params[:badge_set_id])
    @badge = @badge_set.badges.build(params[:badge])

    respond_to do |format|
      if @badge.save
        format.html { redirect_to @badge_set, notice: 'Badge was successfully created.' }
        format.json { render json: @badge, status: :created, location: @badge }
      else
        format.html { render action: "new" }
        format.json { render json: @badge.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @badge_set = BadgeSet.find(params[:badge_set_id])
    @badge = Badge.find(params[:id])

    respond_to do |format|
      if @badge.update_attributes(params[:badge])
        format.html { redirect_to @badge_set, notice: 'Badge was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @badge.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @badge = Badge.find(params[:id])
    @badge.destroy

    respond_to do |format|
      format.html { redirect_to badges_url }
      format.json { head :ok }
    end
  end
  
  def onetime
    @badges = Badge.find_all_by_occurrence(true)
  end
end
