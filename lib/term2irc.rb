require "term2irc/version"

# FIXME: This module breaks some termi ANSI pattern,
# such as: "\e[31;0;42mhello, world\e[0m"
# This must remain string green-backgrounded,
# but currently it would truncate all the color info.

module Term2irc
  ATTRIBUTE_TABLE = {
    :reset     => ["0", "\x0f"],
    :bold      => ["1", "\x02"],
    :underline => ["4", "\x1f"],
  }
  ATTRIBUTE_T2I_TABLE = Hash[ATTRIBUTE_TABLE.map{|r| r[1] }]
  ATTRIBUTE_I2T_TABLE = Hash[ATTRIBUTE_TABLE.map{|r| r[1].reverse }]

  COLOR_TABLE = {
    :black   => ["0", "1"],
    :red     => ["1", "4"],
    :green   => ["2", "3"],
    :yellow  => ["3", "8"],
    :blue    => ["4", "12"],
    :magenta => ["5", "13"],
    :cyan    => ["6", "11"],
    :white   => ["7", "0"],
  }
  COLOR_T2I_TABLE = Hash[COLOR_TABLE.map{|r| r[1] }]
  COLOR_I2T_TABLE = Hash[COLOR_TABLE.map{|r| r[1].reverse }]

  RE_TERMINAL_SEQUENCE = /(\e\[(?:\d+(?:;\d+)*)m)/

  extend self
  def t2i(str)
    str.gsub(RE_TERMINAL_SEQUENCE) do |part|
      meta_to_irc(term_ansi_to_meta(part))
    end
  end

  def term_ansi_to_meta(part)
    meta = {}
    sequences = part.tr("\e[m", '').split(';')
    sequences.each do |sequence|
      # TODO: DRY...
      case sequence
      when "0"
        meta[:reset] = true
      when "1"
        meta[:bold] = true
      when "4"
        meta[:underline] = true
      when /^3[0-7]$/
        meta[:foreground] = sequence[1]
      when /^4[0-7]$/
        meta[:background] = sequence[1]
      end
    end
    return meta
  end

  def meta_to_irc(meta)
    words = ""
    if meta[:reset]
      words << ATTRIBUTE_TABLE[:reset][1]
    end
    if meta[:bold]
      words << ATTRIBUTE_TABLE[:bold][1]
    end
    if meta[:underline]
      words << ATTRIBUTE_TABLE[:underline][1]
    end

    if meta[:foreground] or meta[:background]
      f = meta[:foreground]
      b = meta[:background]
      words << "\x03"
      if f and !b
        words << "#{COLOR_T2I_TABLE[f]}"
      else
        words << "#{f && COLOR_T2I_TABLE[f]},#{COLOR_T2I_TABLE[b]}"
      end
    end
    return words
  end
end
