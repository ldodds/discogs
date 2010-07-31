$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'test/unit'
require 'Artist'

class URITest < Test::Unit::TestCase

  def test_with_the
    name = "Persuader, The"
    assert_equal("http://discogs.dataincubator.org/artist/the-persuader", Artist.create_uri(name) )
  end

  def test_with_and
    name = "Mr. James Barth & A.D."
    assert_equal("http://discogs.dataincubator.org/artist/mr-james-barth-and-ad", Artist.create_uri(name) )
  end

  def test_with_space
    name = "Josh Wink"
    assert_equal("http://discogs.dataincubator.org/artist/josh-wink", Artist.create_uri(name) )
  end   

  def test_with_apos
    name = "Melodies Maker's"
    assert_equal("http://discogs.dataincubator.org/artist/melodies-makers", Artist.create_uri(name) )
  end   
  
        
end
