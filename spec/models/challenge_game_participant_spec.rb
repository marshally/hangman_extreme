require 'spec_helper'

describe ChallengeGameParticipant do

  context "Validation" do

    it { should validate_presence_of(:user_id) }
    it { should validate_uniqueness_of(:user_id).scoped_to(:challenge_game_id)  }

  end

  context "Associations" do

    it { should belong_to(:user) }
    it { should belong_to(:challenge_game) }

  end

end
