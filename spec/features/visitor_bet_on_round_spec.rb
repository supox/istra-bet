require "rails_helper"

RSpec.feature 'Visitor bet on round' do
  let(:user) { create(:user) }
  let(:tournament) { create(:tournament) }
  let(:round) { create(:round, tournament: tournament) }
  let(:game1) do
    create(:game, round: round, bet_points: 2,
                  result: :tie, team1: "Argentina", team2: "Brazil",
                  description: "Game 1 desc")
  end
  let(:game2) do
    create(:game, round: round, bet_points: 3,
                  result: :team1, team1: "Spain", team2: "Korea",
                  description: "Game 2 desc")
  end
  let(:round2) { create(:round, tournament: tournament) }

  let(:mc_round) { create(:round, tournament: tournament) }
  let(:mc) do
    create(:multi_choice, round: mc_round, bet_points: 5,
                  result: "France", options: ["Austria", "Spain", "France"],
                  description: "World cup winner")
  end

  before do
    sign_in user
    game1
    game2
    mc
  end

  scenario 'Visit tournament' do
    visit tournament_path(tournament)
    expect(page).to have_link(round.name, href: round_path(round))
    expect(page).to have_link("Bet!", href: bet_round_path(round))
    expect(page).to have_link("ics Calendar", href: calendar_round_path(round))
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

  scenario 'Visit round 2 bet should have the right tournament link' do
    round
    visit bet_round_path(round2)
    click_link(tournament.name)

    expect(page).to have_current_path(tournament_path(tournament))
  end

  scenario 'Visit mc_round bet' do
    visit bet_round_path(mc_round)
    mc.options.each{|o| expect(page).to have_content(o) }
    expect(page).to have_content(mc.description)

    within(:css, "#bet_on_game_#{mc.id}") do
      choose("France")  # right answer - 5 points
    end

    click_button("Bet!")

    expect(page).to have_content("#{user} - 5 points")
  end

end
