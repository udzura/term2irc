require 'helper'

class Term2IRCTest < Test::Unit::TestCase
  test 'simple convert' do
    result = Term2IRC.t2i("\e[1;4;30;43mgood morning\e[0m")
    assert_equal "\u0002\u001F\u00031,8good morning\u000F", result
  end
end
