class RoundsController < ApplicationController
  before_action :set_round, only:
      [:show, :edit, :update, :destroy, :bet, :update_bet, :calendar, :mail, :send_mail]
  before_action :set_bets, only: [:show, :bet]
  before_action :set_tournament, only: [:new, :create]
  before_action :validate_admin, except: [:show, :bet, :update_bet, :calendar]

  # GET /rounds/1
  # GET /rounds/1.json
  def show
  end

  # GET /rounds/new
  def new
    @round = @tournament.rounds.build
    @round.games.build # start with at least one game
    @form_for = [@tournament, @round]
  end

  # GET /rounds/1/edit
  def edit
    @form_for = @round
  end

  # POST /rounds
  # POST /rounds.json
  def create
    @round = @tournament.rounds.build(round_params)

    respond_to do |format|
      if @round.save
        format.html do redirect_to @round, notice: 'Round was successfully created.' end
        format.json { render :show, status: :created, location: @round }
      else
        @form_for = [@tournament, @round]
        format.html do render :new end
        format.json { render json: @round.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rounds/1
  # PATCH/PUT /rounds/1.json
  def update
    respond_to do |format|
      if @round.update(round_params)
        format.html do redirect_to @round, notice: 'Round was successfully updated.' end
        format.json { render :show, status: :ok, location: @round }
      else
        @form_for = @round
        format.html do render :edit end
        format.json { render json: @round.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rounds/1
  # DELETE /rounds/1.json
  def destroy
    tournament = @round.tournament
    @round.destroy
    respond_to do |format|
      format.html do
        redirect_to tournament_path(tournament), notice: 'Round was successfully destroyed.'
      end
      format.json { head :no_content }
    end
  end

  # GET /rounds/1/bet
  def bet
    redirect_to round_path(@round), flash: {error: "Round is closed for bets."} unless @round.open?
  end

  # PUT /rounds/1/bet
  def update_bet
    respond_to do |format|
      # sanitize bets
      bets = params.require(:bets)
      if @round.update_bets(bets, current_user)
        format.html do redirect_to round_path(@round), notice: 'Bets were successfully updated.' end
        format.json { render :show, status: :ok, location: @round }
      else
        format.html do
          @bets = @round.bets current_user
          render :bet
        end
        format.json { render json: @round.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /rounds/1/calendar
  def calendar
    send_data @round.calendar, content_type: 'text/calendar', filename: "round_#{@round.id}.ics"
  end

  # PUT /rounds/1/mail
  def mail
    @mail = RoundMail.new(
      subject: "#{@round} is open for bets!",
      body: "Ready to bet on #{@round}?\r\nRound is now open!"
    )
  end

  # PUT /rounds/1/send_mail
  def send_mail
    respond_to do |format|
      data = params.require(:round_mail).permit(:body, :subject)
      @mail = RoundMail.new(data)
      if @mail.valid?
        RoundsMailer.notify_round(@mail.body, @mail.subject, @round, User.confirmed.all).deliver_now
        format.html { redirect_to round_path(@round), notice: 'Sent email successfully.' }
        format.json { render :show, status: :ok, location: @round }
      else
        format.html { render :mail }
        format.json { render json: @mail.errors, status: :unprocessable_entity }
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
    params.require(:round).permit(:name, :expiration_date, :tournament_id,
                                  games_attributes: [
                                    :id, :description, :team1,
                                    :team2, :start_time,
                                    :bet_points, :result, :_destroy
                                  ])
  end
end
