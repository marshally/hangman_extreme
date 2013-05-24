module Domain
  module PlayChallengeGame

    def self.included(base)
      base.state_machine :initial => 'created'  do

        before_transition 'waiting_for_opponent' => 'started' do |game, transition|
          game.active_player = game.players.first
        end

        event :add_player do
          transition 'created' => 'waiting_for_opponent', 'waiting_for_opponent' => 'started'
        end

        event :play_letter do
          transition 'started' => 'completed', :if => lambda {|game| game.done? }
        end

        state 'started' do
          def add_choice(letter)
            self.choices ||= ""
            return if letter.to_s.size > 1
            letter.downcase!
            if letter =~ /\p{Lower}/
              self.choices += letter
              word.include?(letter)
            else
              false
            end
          end
        end

      end

      base.class_eval do
        include Methods
      end
    end

    module Methods

      def add_player(player = nil,*args)
        players << player
        super
        self
      end

      def switch_active_player
        self.active_player = inactive_player
      end

      def done?
        (word_letters - choice_letters).empty?
      end

      def play_letter(letter = nil,*args)
        if add_choice(letter)
          super
        else
          switch_active_player
        end
      end

      private

      def word_letters
        word.to_s.split("")
      end

      def choice_letters
        choices.to_s.split("")
      end

    end

  end
end