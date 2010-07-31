require 'rubygems'
require 'libxml'
require 'rdf'
require 'uri'
require 'cgi'
require 'Util'
require 'Vocabulary'
require 'NamedDiscogResource'

class Artist < NamedDiscogResource
  
  def initialize(string)
    super(string)

    @realname = get_optional_tag("realname")
    #@profile = get_optional_tag("profile")
    profile = @root.find_first("profile")
    if profile != nil
      @profile = profile.first.content
    end
        
    #aliases
    #each is a separate record. Should be preserved as distinct entities, not really sameas?
    
    #groups
    @groups = Array.new
    groups = @root.find_first("groups")
    if groups != nil 
      groups.find("name").each do |group|
          if group.first.content != nil && group.first.content != ""
            name = Util.clean_ws(group.first.content)
            if name != nil
              @groups << Artist.create_uri( name ) 
            end                       
          end
      end      
    end        
    
  end  
  
  def statements()
    statements = Array.new
    uri = RDF::URI.new( Artist.create_uri( @raw_name ) )
    statements << RDF::Statement.new( uri, RDF.type, RDF::URI.new( rdf_type() ) )
    statements << RDF::Statement.new( uri, Vocabulary::FOAF.name, RDF::Literal.new(@name) )
    
    if @realname
      statements << RDF::Statement.new( uri, Vocabulary::FOAF.name, RDF::Literal.new(@realname) )
    end

    statements << RDF::Statement.new( uri, Vocabulary::MO.discogs, RDF::URI.new("http://www.discogs.com/artist/#{ CGI::escape(@raw_name) }") )
        
    @urls.each do |url|      
      
      #hack to strip comments after urls in data
      #TODO: comma-sep
      url = url.split(" ")[0]
      url = Util.clean_url(url)
      begin
        
        URI.parse(url)
              
        if ( /twitter\.com\/([a-zA-Z0-9]+)/.match(url) )          
          statements << RDF::Statement.new( uri, Vocabulary::FOAF.holdsAccount, RDF::URI.new( url ) )
          statements << RDF::Statement.new( RDF::URI.new( url ) , RDF.type, Vocabulary::FOAF.OnlineAccount )
          statements << RDF::Statement.new( RDF::URI.new( url ) , RDF.type, Vocabulary::SIOC.User )                  
        else
          statements << RDF::Statement.new( uri, Vocabulary::FOAF.isPrimaryTopicOf, RDF::URI.new( url ))
          statements << RDF::Statement.new( RDF::URI.new( url ), Vocabulary::FOAF.primaryTopic, uri )
        end
        
        if ( /en\.wikipedia\.org/.match(url) )    
          dbpedia_uri = url.sub("en.wikipedia.org/wiki", "dbpedia.org/resource")
          statements << RDF::Statement.new( uri, Vocabulary::OWL.sameAs, RDF::URI.new( dbpedia_uri ) )
        end
  
        if ( /wikipedia\.org/.match(url) )
          statements << RDF::Statement.new( uri, Vocabulary::MO.wikipedia, RDF::URI.new( url ) )
        end            
        
        if ( /www\.myspace\.com/.match(url) )
          statements << RDF::Statement.new( uri, Vocabulary::MO.myspace, RDF::URI.new( url ))
          
          #TODO using seeAlso rather than sameas as sometimes records have >1 myspace account associated with them  
          dbtune_uri = url.sub("www.myspace.com", "dbtune.org/myspace")
          statements << RDF::Statement.new( uri, RDF::RDFS.seeAlso, RDF::URI.new( dbtune_uri ) )
        end
      rescue
        puts "invalid URI: #{url}"
      end            
    end
    
    @groups.each do |group|
      statements << RDF::Statement.new( uri, Vocabulary::MO.member_of, RDF::URI.new( group ) )
    end
        
    @images.each do |image|
      statements << RDF::Statement.new( uri, Vocabulary::FOAF.depiction, RDF::URI.new( image["uri"] ))
      statements = statements + dump_image(image, RDF::Literal.new("Photo of #{@raw_name}"), uri)
    end
        
    if @profile != nil
      statements << RDF::Statement.new( uri, Vocabulary::DCTERMS.description, RDF::Literal.new( @profile ) )
    end    
    
    return statements    
  end
    
  def rdf_type()
    if @root.find("members").length() == 0
      return "http://purl.org/ontology/mo/MusicArtist"
    end
    return "http://purl.org/ontology/mo/MusicGroup"
  end
  
  def Artist.create_uri(name)
    slug = Util.slug(name)
    return Util.canonicalize("/artist/#{ CGI.escape(slug) }")
  end
      
end