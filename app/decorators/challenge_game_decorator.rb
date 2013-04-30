class ChallengeGameDecorator < Draper::Decorator
  delegate_all

  def hangman_text
    text = word.clone
    word_letters.each{|letter| text.gsub!(letter,"_") unless choices.to_s.include?(letter)}
    text.split("").join(" ")
  end

  protected

  def word_letters
    word.to_s.split("")
  end

end
