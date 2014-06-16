require 'nokogiri'

class Refixative::Parser
  # html: String, or File
  def parse_profile(html)
    _parse_profile(Nokogiri::HTML(html) { |config| config.nonet })
  end

  def parse_music(html)
    _parse_music(Nokogiri::HTML(html) { |config| config.nonet })
  end

  private

  def _parse_profile(_)
    fail NotImplementedError
  end

  def _parse_music(_)
    fail NotImplementedError
  end

  def get_str(el)
    el.text.strip
  end

  def get_int(el)
    get_str(el).to_i
  end

  def name_normalize(name)
    name.gsub(/''/, '"')  # double single quote -> double quote
        .gsub(/　/, ' ')  # full-width space -> half-width space
        .gsub(/ +/, ' ')  # continuous half-width space -> one half-width space
        .gsub(/−/, '—')  # full-width hyphen -> full-width dash
        .gsub(/—+/, '—')  # continuous full-width dash -> single full-width dash
        .gsub(/[\uff5e]/, "\u301c")  # full-width tilde -> full-width wave dash
        .gsub(/[\u2012\u2013\u2015\u2212\uff0d]/, "\u2014")  # hyphen and dashes
        .strip
  end
end
