$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'Artist'

f = File.new(ARGV[0])
data = f.read()
artist = Artist.new(data)
writer = RDF::NTriples::Writer.new( $stdout )
artist.statements.each do |stmt|
  writer << stmt
end
