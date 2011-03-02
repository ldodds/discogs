require 'libxml'
require 'uri'
require 'cgi'
require 'Util'
require 'DiscogResource'
require 'Artist'
require 'Release'

class Track
  
  attr_reader :title
  
  def initialize(release_id, element, number)
    @element = element
    @number = number
    @release_id = release_id
    position = element.find_first("position").first
    if position != nil
      @position = position.content
    end
    title = element.find_first("title").first
    @title = title.content if title && title.content
    #puts element.find_first("title").inspect()
    #puts @title.inspect()
    
    artists = @element.find_first("artists")
    @artists = []
    if artists != nil
      artists.find("artist").each do |artist|
        name = artist.find_first("name").first.to_s
        @artists << Artist.create_uri( name )
      end      
    end
    
    #duration
    duration = @element.find_first("duration")
    if duration && duration.first.to_s != ""
      duration = duration.first.to_s.gsub("'", "M")
      duration = duration.first.to_s.gsub(":", "M")      
      @duration="PT#{duration}S"
    end
    
    #TODO
    #extrartists -> role. See roles.txt
    
  end
  
  def uri()
    return Track.create_uri(@release_id, @position)    
  end
  
  def statements
    statements = Array.new
    uri = RDF::URI.new( Track.create_uri(@release_id, @position) )
    statements << RDF::Statement.new( uri, RDF.type, Vocabulary::MO.Track )
    
    if @title
      statements << RDF::Statement.new( uri, Vocabulary::DCTERMS.title, RDF::Literal.new( @title ) )
    end

    statements << RDF::Statement.new( uri, Vocabulary::DCTERMS.isPartOf, RDF::URI.new( Release.create_uri(@release_id) ) )     

    #TODO resolve whether to use consecutive numbering or alphanumeric. Could rdf:List and record position too?
    #Note not using discogs position here, as its alphanumeric. Why is that? A1, A2, B1, B2 -- sides of record?
    #If so, then our track number is consecutive across sides of media
    statements << RDF::Statement.new( uri, Vocabulary::MO.track_number, RDF::Literal.new(@number, :datatype => RDF::XSD.int ))
    
    if @duration
      statements << RDF::Statement.new( uri, Vocabulary::OWLTIME.duration, RDF::Literal.new(@duration, :datatype => RDF::XSD.duration))
    end
        
    @artists.each do |artist|
      statements << RDF::Statement.new( uri, Vocabulary::FOAF.maker, RDF::URI.new( artist ) )
      statements << RDF::Statement.new( RDF::URI.new( artist ), Vocabulary::FOAF.made, uri )
    end
    
    return statements
  end
    
  def Track.create_uri(release_id, position)
    #using position rather than title
    if position
      slug = Util.slug(position)
    else
      slug = "unknown"  
    end    
    return Util.canonicalize("/release/#{release_id}/track/#{ CGI.escape(slug) }")    
  end
  
end