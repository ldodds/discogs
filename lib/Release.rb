require 'libxml'
require 'uri'
require 'cgi'
require 'Util'
require 'DiscogResource'
require 'Label'
require 'Artist'
require 'Track'
class Release < DiscogResource
  
  attr_reader :id, :title, :artists, :labels, :notes, :released, :tracks, :genres, :styles
  
  def initialize(string)    
    super(string)
    @id = @root.attributes["id"]
    @title = @root.find_first("title").first.content
    artists = @root.find_first("artists")
    @artists = []
    artists.find("artist").each do |artist|
      name = artist.find_first("name").first
      if name && name.content
        @artists << Artist.create_uri( name.content )  
      end      
    end

    labels = @root.find_first("labels")
    @labels = []
    labels.find("label").each do |label|
      #TODO catno
      name = label.attributes["name"]
      @labels << Label.create_uri( name )
    end
        
    notes = @root.find_first("notes")
    @notes = notes.first.content unless notes == nil
    released = @root.find_first("released")
    if released
      @released = released.first.content
      #clean up dates
      if @released.match("-00-00")
        @released = @released[0..3]
      end
      if @released.match("-00")
        @released = @released[0..@released.length-4]
      end    
      if @released.length == 4
        @release_date_format = "http://www.w3.org/2001/XMLSchema#year"
      elsif @released.length == 7
        @release_date_format = "http://www.w3.org/2001/XMLSchema#gYearMonth"
      else
        @release_date_format = "http://www.w3.org/2001/XMLSchema#date"  
      end

    end
    
    
    tracklist = @root.find_first("tracklist")
    @tracks = []
    if tracklist != nil    
      tracklist.find("track").each_with_index do |track, i|
        @tracks << Track.new(@id, track, i+1)
      end      
    end
    
    #genres & styles -> SKOS
    genres = @root.find_first("genres")
    @genres = []
    if genres
      genres.find("genre").each do |genre|
        @genres << genre
      end
    end
        
    styles = @root.find_first("styles")
    @styles = []
    if styles
      styles.find("style").each do |style|
        @styles << style
      end
    end
        
    #TODO 
    #discogs record status
    #formats -> Manifestation?    
    #country (where released)
  end
  
  def statements()
    statements = Array.new
    uri = RDF::URI.new( Release.create_uri(@id) )
    statements << RDF::Statement.new( uri, RDF.type, Vocabulary::MO.Record )
    statements << RDF::Statement.new( uri, Vocabulary::DCTERMS.title, RDF::Literal.new( @title ) )
    statements << RDF::Statement.new( uri, Vocabulary::MO.discogs, RDF::URI.new("http://www.discogs.com/release/#{ @id }"))
    
    if @notes != nil
      statements << RDF::Statement.new( uri, RDF::RDFS.comment, RDF::Literal.new( @notes ))
    end
      
    if @released    
      statements << RDF::Statement.new( uri, Vocabulary::DCTERMS.issued, RDF::Literal.new( @released, :datatype => RDF::URI.new(@release_date_format) ) )
    end
    
    @images.each do |image|
      statements << RDF::Statement.new( uri, Vocabulary::FOAF.depiction, RDF::URI.new( image["uri"] ) )
      statements = statements + dump_image(image, RDF::Literal.new("Photo of #{@title}"), uri)
    end
    
    @artists.each do |artist|
      statements << RDF::Statement.new( uri, Vocabulary::FOAF.maker, RDF::URI.new( artist ) )
    end

    @labels.each do |label|
      statements << RDF::Statement.new( uri, Vocabulary::MO.publisher, RDF::URI.new( label ))
    end

    @tracks.each do |track|
      statements << RDF::Statement.new( uri, Vocabulary::MO.track, RDF::URI.new( track.uri ) )
      statements = statements + track.statements
    end
    
    #TODO genres and formats -- these will be skos concepts linked to relevant scheme
    #but how do we associate a Record with its scheme. Its not its "subject" or "topic" 
    
    return statements    
  end
      
  def Release.create_uri(id)
    return Util.canonicalize("/release/#{id}")
  end
end