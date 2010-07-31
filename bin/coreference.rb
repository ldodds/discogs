require 'rubygems'
require 'rdf'

LINKS = Hash.new

#For links files with common patterns
#E.g. X :foo Y
#
# A :foo Y
#
# therefore:
# A owl:sameAs X

puts "Parsing N-Triples"
RDF::NTriples::Reader.open(ARGV[0]) do |reader|
  reader.each_statement do |statement|
    LINKS[statement.object.to_s] = statement.subject.to_s
  end
end

puts "Scanning N-Triples"
RDF::NTriples::Writer.new(File.new(ARGV[2], "w")) do |writer|
  
  RDF::NTriples::Reader.open(ARGV[1]) do |reader|
    reader.each_statement do |statement|
      uri = LINKS[statement.object.to_s]
      if uri != nil
        writer << RDF::Statement.new( statement.subject, RDF::OWL.sameAs, RDF::URI.new(uri) )
      end        
    end
    
  end
  
end