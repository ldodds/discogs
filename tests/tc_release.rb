$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'test/unit'
require 'Release'

class ReleaseTest < Test::Unit::TestCase
  
TEST = <<-EOL
  <release id="46" status="Accepted">
  <images>
  <image height="247" type="secondary" uri="http://www.discogs.com/image/R-46-1114052082.jpg" uri150="http://www.discogs.com/image/R-150-46-1114052082.jpg" width="330" />
  </images>
  <artists>
  <artist><name>H&#195;&#165;kan Lidbo</name><anv>H&#195;&#165;kan</anv><join>Presents</join></artist>
  <artist><name /></artist>
  </artists>
  <title>New Standards</title>
  <labels>
  <label catno="LOAD 059" name="Loaded Records" />
  </labels>
  <formats>
  <format name="Vinyl" qty="1">
  <descriptions>
  <description>12"</description>
  </descriptions>
  </format>
  </formats>
  <genres>
  <genre>Electronic</genre>
  </genres>
  <styles>
  <style>House</style>
  </styles>
  <country>UK</country>
  <released>1999</released>
  <tracklist>
  <track><position>A1</position><title>Bug</title><extraartists><artist><name>Laid</name><role>Featuring</role></artist><artist><name>Johan Emmoth</name><anv>J. Emmoth</anv><role>Producer, Written-By</role></artist><artist><name>John Andersson</name><anv>J. Andersson</anv><role>Producer, Written-By</role></artist></extraartists><duration /></track>
  <track><position>A2</position><title>Keep On Dancing</title><duration /></track>
  <track><position>B1</position><title>Smooth Intruder</title><duration /></track>
  <track><position>B2</position><title>Relax...</title><duration /></track>
  </tracklist>
  </release>   
EOL

TEST2 = <<-EOL
  <release id="5377" status="Accepted"><images><image height="600" type="secondary" uri="http://www.discogs.com/image/R-5377-1185068106.jpeg" uri150="http://www.discogs.com/image/R-150-5377-1185068106.jpeg" width="600" /></images><artists><artist><name>H&#195;&#165;kan Lidbo</name></artist></artists><title>After The End</title><labels><label catno="APR049CD" name="April Records" /></labels><formats><format name="CD" qty="1"><descriptions><description>Album</description></descriptions></format></formats><genres><genre>Electronic</genre></genres><styles><style>Abstract</style><style>IDM</style><style>Experimental</style></styles><country>Denmark</country><released>2000</released><notes>Written and produced at Container Studios, Stockholm.
  Additional sounds created at EMS, Stockholm.
  Mastered at Polar Studios, Stockholm.
  Tracks flow one after the other without silence in between.
  Track 13 contains a hidden track (track 13.2). Track 13.1 lasts for 1:00 before a period of silence.
  
  &lt;i&gt;Dedicated to the memory of my father.&lt;/i&gt;
  </notes><tracklist><track><position>1</position><title>XOR4</title><duration>1:03</duration></track><track><position /><title>Part 1</title><duration /></track><track><position>2</position><title>Open Circle</title><duration>3:37</duration></track><track><position /><title>Part 2</title><duration /></track><track><position>3</position><title>Prewinder</title><extraartists><artist><name>Fredrik Davidsson</name><role>Flugelhorn</role></artist></extraartists><duration>2:25</duration></track><track><position>4</position><title>Ovaloids</title><extraartists><artist><name>Jonas Broberg</name><role>Synthesizer [Serge]</role></artist></extraartists><duration>11:39</duration></track><track><position /><title>Part 3</title><duration /></track><track><position>5</position><title>Hypercube</title><duration>4:19</duration></track><track><position>6</position><title>Undo Undone</title><duration>5:19</duration></track><track><position>7</position><title>XOR5</title><duration>0:37</duration></track><track><position /><title>Part 4</title><duration /></track><track><position>8</position><title>Noise Objects</title><duration>3:33</duration></track><track><position>9</position><title>After The End</title><duration>5:58</duration></track><track><position>10</position><title>Dysfunctionalism</title><duration>3:34</duration></track><track><position /><title>Part 5</title><duration /></track><track><position>11</position><title>Bi-Angular</title><duration>7:38</duration></track><track><position>12</position><title>Redo Undone</title><duration>3:11</duration></track><track><position /><title>-</title><duration /></track><track><position>13.1</position><title /><duration>16:30</duration></track><track><position>13.2</position><title>XOR6</title><duration>0:27</duration></track></tracklist></release>
EOL

   def test_parse_with_missing_author_name()
     release = Release.new(TEST)  
     assert_equal("46", release.id)
     assert_equal("New Standards", release.title)
     assert_equal(1, release.artists.length)
     assert_equal(1, release.labels.length)
     assert_equal("http://discogs.dataincubator.org/label/loaded-records", release.labels[0])
     assert_equal(1, release.genres.length)
     assert_equal(1, release.styles.length)
     assert_equal("1999", release.released)
     assert_equal(4, release.tracks.length)
   end
   
   def test_parse2()
     release = Release.new(TEST2)  
   end
end