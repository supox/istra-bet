require "application_system_test_case"

class BetsTest < ApplicationSystemTestCase
  setup do
    @bet = bets(:one)
  end

  test "visiting the index" do
    visit bets_url
    assert_selector "h1", text: "Bets"
  end

  test "creating a Bet" do
    visit bets_url
    click_on "New Bet"

    fill_in "Answer", with: @bet.answer
    fill_in "Game", with: @bet.game_id
    fill_in "User", with: @bet.user_id
    click_on "Create Bet"

    assert_text "Bet was successfully created"
    click_on "Back"
  end

  test "updating a Bet" do
    visit bets_url
    click_on "Edit", match: :first

    fill_in "Answer", with: @bet.answer
    fill_in "Game", with: @bet.game_id
    fill_in "User", with: @bet.user_id
    click_on "Update Bet"

    assert_text "Bet was successfully updated"
    click_on "Back"
  end

  test "destroying a Bet" do
    visit bets_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Bet was successfully destroyed"
  end
end
