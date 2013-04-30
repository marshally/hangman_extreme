class Ability
  include CanCan::Ability

  def initialize(user)
    can [:read,:play_letter,:show_clue,:reveal_clue], Game, user_id: user.id
    can :read, ChallengeGame do |challenge_game|
      challenge_game.user_ids.include?(user.id)
    end
    can :play_letter, ChallengeGame do |challenge_game|
      challenge_game.active_participant.user_id == user.id
    end

    can :read, Winner
    can :read, User

    can :update, user

    can :read, PurchaseTransaction, user_id: user.id
    can :read, RedeemWinning, user_id: user.id
    can :read, AirtimeVoucher, user_id: user.id
    can :read, Feedback, user_id: user.id

    unless user.guest?
      can :create, [PurchaseTransaction,RedeemWinning,Game,ChallengeGame,Feedback]
    end
  end
end
