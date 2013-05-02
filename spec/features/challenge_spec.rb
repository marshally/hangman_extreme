require 'spec_helper'

describe 'challenge', :redis => true, :shinka_vcr => true, :smaato_vcr => true do

  before :all do
    Capybara.javascript_driver = :selenium
  end

  after :all do
    Capybara.javascript_driver = :poltergeist
  end

  def setup_two_sessions(options = {})
    options.reverse_merge!(facebook: '1234567', mxit: 'm2604100')
    @facebook_user = User.find_facebook_user(options[:facebook]) || create(:user, uid: options[:facebook], provider: 'facebook')
    @mxit_user = User.find_mxit_user(options[:mxit]) || create(:user, uid: options[:mxit], provider: 'mxit')
    using_session(:facebook) do
      using_facebook_omniauth{visit '/auth/facebook'}
    end
    using_session(:mxit) do
#      set_mxit_headers(options[:mxit]) # set mxit user
      visit(test_login_path(id: @mxit_user.id))
    end
  end

  def click_letter(l)
    within(".letters") do
      click_link(l)
    end
  end

  it "must allow to play against another player", :js => true do
    Dictionary.clear
    Dictionary.add("challenger")
    setup_two_sessions
    using_session(:facebook) do
      click_link 'challenge'
      click_link 'find opponent'
      page.should have_content("Waiting for opponent")
    end
    using_session(:mxit) do
      click_link 'challenge'
      click_link 'find_opponent'
      page.should have_content("_ _ _ _ _ _ _ _ _ _")
      page.should have_content("Opponent's Turn")
      within(".letters") do
        page.should_not have_link('a')
      end
    end
    using_session(:facebook) do
      page.should have_content("Your Turn")
      page.should have_content("_ _ _ _ _ _ _ _ _ _")
      click_letter 'a'
      page.should have_content("_ _ a _ _ _ _ _ _ _")
    end
    using_session(:mxit) do
      page.should have_content("_ _ a _ _ _ _ _ _ _")
    end
    using_session(:facebook) do
      click_letter 'b'
      page.should have_content("Opponent's Turn")
      page.should have_content("_ _ a _ _ _ _ _ _ _")
      within(".letters") do
        page.should_not have_link('c')
      end
    end
    using_session(:mxit) do
      page.should have_content("Your turn to play")
      click_letter 'play'
      page.should have_content("Your Turn")
      page.should have_content("_ _ a _ _ _ _ _ _ _")
      within(".letters") do
        page.should_not have_link('b')
      end
      click_letter 'c'
      page.should have_content("c _ a _ _ _ _ _ _ _")
    end
    using_session(:facebook) do
      page.should have_content("c _ a _ _ _ _ _ _ _")
      page.should have_content("Opponent's Turn")
      within(".letters") do
        page.should_not have_link('d')
      end
    end
  end

end