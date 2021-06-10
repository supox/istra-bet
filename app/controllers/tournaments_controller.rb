class TournamentsController < ApplicationController
  before_action :set_tournament, only: [:show, :edit, :update, :destroy, :mail, :send_mail]
  before_action :validate_admin, except: [:index, :show]

  # GET /tournaments
  # GET /tournaments.json
  def index
    @tournaments = Tournament.all
  end

  # GET /tournaments/1
  # GET /tournaments/1.json
  def show
  end

  # GET /tournaments/new
  def new
    @tournament = Tournament.new
  end

  # GET /tournaments/1/edit
  def edit
  end

  # POST /tournaments
  # POST /tournaments.json
  def create
    @tournament = Tournament.new(tournament_params)

    respond_to do |format|
      if @tournament.save
        format.html { redirect_to @tournament, notice: 'Tournament was successfully created.' }
        format.json { render :show, status: :created, location: @tournament }
      else
        format.html { render :new }
        format.json { render json: @tournament.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tournaments/1
  # PATCH/PUT /tournaments/1.json
  def update
    respond_to do |format|
      if @tournament.update(tournament_params)
        format.html { redirect_to @tournament, notice: 'Tournament was successfully updated.' }
        format.json { render :show, status: :ok, location: @tournament }
      else
        format.html { render :edit }
        format.json { render json: @tournament.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tournaments/1
  # DELETE /tournaments/1.json
  def destroy
    @tournament.destroy
    respond_to do |format|
      format.html { redirect_to tournaments_url, notice: 'Tournament was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # PUT /tournaments/1/mail
  def mail
    @mail = TournamentMail.new(
      subject: "#{@tournament}",
      body: "Ready to bet on #{@tournament}?"
    )
  end

  # PUT /tournament/1/send_mail
  def send_mail
    respond_to do |format|
      data = params.require(:tournament_mail).permit(:body, :subject)
      @mail = TournamentMail.new(data)
      if @mail.valid?
        User.subscribed.each{|user| TournamentsMailer.notify_tournament(@mail.body, @mail.subject, @tournament, user).deliver_later }
        format.html { redirect_to tournament_path(@tournament), notice: 'Sent email successfully.' }
        format.json { render :show, status: :ok, location: @tournament }
      else
        format.html { render :mail }
        format.json { render json: @mail.errors, status: :unprocessable_entity }
      end
    end
  end
  private

  # Use callbacks to share common setup or constraints between actions.
  def set_tournament
    @tournament = Tournament.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def tournament_params
    params.require(:tournament).permit(:name, :description)
  end
end
