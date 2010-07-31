$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'Release'

f = File.new(ARGV[0])
data = f.read()
release = Release.new(data)
writer = RDF::NTriples::Writer.new( $stdout )
release.statements.each do |stmt|
  writer << stmt
end
