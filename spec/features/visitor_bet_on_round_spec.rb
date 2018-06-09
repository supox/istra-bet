require 'spec_helper'

feature 'Visitor bet on round' do
  let(:user) {create(:user)}
  let(:tournament) {create(:tournament)}
  let(:round) {create(:round, tournament: tournament)}
  let(:game1) {create(:game, round: round, bet_points: 2, result: :tie, team1: "Argentina", team2: "Brazil", description: "Game 1 desc")}
  let(:game2) {create(:game, round: round, bet_points: 3, result: :team1, team1: "Spain", team2: "Korea", description: "Game 2 desc")}

  before do
    sign_in user
    game1
    game2
  end

  scenario 'Visit tournament' do
    visit tournament_path(tournament)
    expect(page).to have_link(round.name, href:round_path(round))
    expect(page).to have_link("Bet!", href: bet_round_path(round))
  end

  scenario 'Visit round bet' do
    visit bet_round_path(round)
    expect(page).to have_content(game1.team1)
    expect(page).to have_content(game1.team2)
    expect(page).to have_content(game1.description)
    expect(page).to have_content(game2.team1)
    expect(page).to have_content(game2.team2)
    expect(page).to have_content(game2.description)

    within(:css, "#bet_on_game_#{game1.id}") do
      choose(game1.team2)  # wrong answer
    end
    within(:css, "#bet_on_game_#{game2.id}") do
      choose(game2.team1)  # right answer - 3 points
    end

    click_button("Bet!")

    expect(page).to have_content("#{user} - 3 points")
  end
end
