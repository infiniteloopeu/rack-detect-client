$:.unshift File.dirname(__FILE__) + '/../lib'
require 'rubygems'
require 'rack'
require 'rack/detect_client'
require 'test/unit'
class RackConfigTest < Test::Unit::TestCase

  def test_all
    flunk
  end
end
