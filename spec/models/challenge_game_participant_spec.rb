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

  context "Scopes" do

    describe "active" do

      it "returns active particpants" do
        particpant = create(:challenge_game_participant, active: true)
        create(:challenge_game_participant, active: false)
        ChallengeGameParticipant.active.should == [particpant]
      end

    end

  end

  context "Instance Methods" do

    describe "turn_done!" do

      it "must inactive" do
        particpant = create(:challenge_game_participant, active: true)
        particpant.turn_done!
        ChallengeGameParticipant.find(particpant.id).should_not be_active
      end

    end

    describe "turn_start!" do

      it "must inactive" do
        particpant = create(:challenge_game_participant, active: false)
        particpant.turn_start!
        ChallengeGameParticipant.find(particpant.id).should be_active
      end

    end

  end

end
