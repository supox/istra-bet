class RoundsController < ApplicationController
  before_action :set_round, only: [:show, :edit, :update, :destroy, :bet, :update_bet]
  before_action :set_bets, only: [:show, :bet]
  before_action :set_tournament, only: [:index, :new, :create]

  # GET /rounds
  # GET /rounds.json
  def index
    @rounds = @tournament.rounds
  end

  # GET /rounds/1
  # GET /rounds/1.json
  def show
  end

  # GET /rounds/new
  def new
    @round = @tournament.rounds.build
  end

  # GET /rounds/1/edit
  def edit
  end

  # POST /rounds
  # POST /rounds.json
  def create
    @round = @tournament.rounds.build(round_params)

    respond_to do |format|
      if @round.save
        format.html { redirect_to @round, notice: 'Round was successfully created.' }
        format.json { render :show, status: :created, location: @round }
      else
        format.html { render :new }
        format.json { render json: @round.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rounds/1
  # PATCH/PUT /rounds/1.json
  def update
    respond_to do |format|
      if @round.update(round_params)
        format.html { redirect_to @round, notice: 'Round was successfully updated.' }
        format.json { render :show, status: :ok, location: @round }
      else
        format.html { render :edit }
        format.json { render json: @round.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rounds/1
  # DELETE /rounds/1.json
  def destroy
    @round.destroy
    respond_to do |format|
      format.html { redirect_to rounds_url, notice: 'Round was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /rounds/1/bet
  def bet
  end

  # PUT /rounds/1/bet
  def update_bet
    respond_to do |format|  # TODO
      # sanitize bets
      bets = params.require(:bets)
      if @round.update_bets(bets, current_user)
        format.html { redirect_to @round, notice: 'Bets were successfully updated.' }
        format.json { render :show, status: :ok, location: @round }
      else
        format.html {
          @bets = @round.bets current_user
          render :bet
        }
        format.json { render json: @round.errors, status: :unprocessable_entity }
      end
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_round
      @round = Round.find(params[:id])
    end

    def set_bets
      @bets = @round.bets current_user
    end

    def set_tournament
      @tournament = Tournament.find(params[:tournament_id])
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def round_params
      params.require(:round).permit(:name, :expiration_date, :tournament_id, games_attributes: [:id, :description, :team1, :team2, :start_time, :bet_points, :result, :_destroy])
    end
end
