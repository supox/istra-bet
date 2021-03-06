class RoundsController < ApplicationController
  before_action :set_round, only:
      [:show, :edit, :update, :destroy, :bet, :update_bet, :calendar, :mail, :send_mail, :users_bets_csv]
  before_action :set_bets, only: [:show, :bet]
  before_action :set_tournament, only: [:new, :create]
  before_action :validate_admin, except: [:show, :bet, :update_bet, :calendar, :users_bets_csv]
  before_action :validate_closed, only: [:users_bets_csv]

  # GET /rounds/1
  # GET /rounds/1.json
  def show
  end

  # GET /rounds/new
  def new
    @round = @tournament.rounds.build
    if params['multi_choice'].present?
      @round.multi_choices.build # start with at least one multi-choice
    else
      @round.games.build # start with at least one game
    end
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
      bets_valid = if @round.games.empty?
        true
      else
        bets = params.require(:bets)
        @round.update_bets(bets, current_user)
      end

      mc_bets_valid = if @round.multi_choices.empty?
        true
      else
        mc_bets = params.require(:mc_bets)
        @round.update_multi_choice_bets(mc_bets, current_user)
      end

      if bets_valid && mc_bets_valid
        format.html do redirect_to round_path(@round), notice: 'Bets were successfully updated.' end
        format.json { render :show, status: :ok, location: @round }
      else
        format.html do
          @bets = @round.bets current_user
          @mc_bets = @round.mc_bets current_user
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

  # GET /rounds/1/users_bets_csv
  def users_bets_csv
    send_data @round.all_users_bets_table_csv, content_type: 'text/csv', filename: "users-bets-#{@round.name.parameterize}.csv"
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
        User.subscribed.each{|user| RoundsMailer.notify_round(@mail.body, @mail.subject, @round, user).deliver_later}
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
    @mc_bets = @round.mc_bets current_user
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
                                  ],
                                 multi_choices_attributes: [
                                    :id, :description, { options: [] },
                                    :bet_points, :result, :_destroy
                                  ] )
      
  end

  def validate_closed
    unless @round.closed?
      render file: "#{Rails.root}/public/401.html", status: :unauthorized
    end
  end
end
