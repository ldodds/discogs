require 'rubygems'
require 'libxml'
require 'rdf'
require 'uri'
require 'cgi'
require 'Util'
require 'Vocabulary'
require 'NamedDiscogResource'

class Label < NamedDiscogResource

  def initialize(string)
    
    super(string)
        
    #TODO parse out the markup
    #[l=Seasons Recordings]
    #[url=http://www.usatt.org/rseguine/FAX/fax_facts/interview/peter_namlook_interview.htm]here[/url]
    #[b]Phone:[/b] +1 (773) 862-0073
    #[b]Founder &amp; Owner:[/b] [a=Jeff Craven]
    #[a=DJ Buck]
    #[i]Theories and subjects of substances is the elementary element that fuels the minds within our Axis.[/i]
    # [r=27120]
    #[b][l=Rising High Records][/b]
    #[u]Partisan Recordings[/u]
    #@profile = get_optional_tag("profile")
    profile = @root.find_first("profile")
    if profile != nil
      @profile = profile.first.content  
    end
    
    
    contact = @root.find_first("contactinfo")
    if contact != nil && contact.first.content != ""
      #FIXME losing \n in addresses, temporarily fixed with space
      @address = Util.clean_escape(contact.first.content)
    end
    
    @parent = get_optional_tag("parentLabel", false)
    
  end

  def statements()    
    statements = Array.new()
        
    uri = RDF::URI.new( uri = Label.create_uri( @raw_name ) )
    statements << RDF::Statement.new( uri, RDF.type, Vocabulary::MO.Label )    
    statements << RDF::Statement.new( uri, Vocabulary::FOAF.name, RDF::Literal.new( @name ) )
    statements << RDF::Statement.new( uri, Vocabulary::MO.discogs, 
        RDF::URI.new("http://www.discogs.com/label/#{CGI::escape(@raw_name)}") )
        
    @urls.each do |url|
      #TDB complains about urls with @ signs in them
      if !url.include?("@")
        #hack to strip comments after urls in data
        #TODO: comma-sep
        url = url.split(" ")[0]
        url = Util.clean_url(url)      
        begin
          #TODO let rdf.rb handle parsing?
          URI.parse(url)
          url = RDF::URI.new( url )
          statements << RDF::Statement.new(uri, Vocabulary::FOAF.isPrimaryTopicOf, RDF::URI.new(url) )
          statements << RDF::Statement.new(url, Vocabulary::FOAF.primaryTopic, RDF::URI.new(uri) )        
        rescue
          puts "Invalid uri #{url}"  
        end
      end
    end
    
    @images.each do |image|
      statements << RDF::Statement.new( uri, Vocabulary::FOAF.logo, RDF::URI.new( image["uri"] ) )
      statements = statements + dump_image(image, RDF::Literal.new( "Logo for #{@raw_name}") )
    end
    
    if @profile != nil && @profile != ""
      statements << RDF::Statement.new( uri, Vocabulary::DCTERMS.description, RDF::Literal.new(@profile) )
    end    
    if @address != nil && @address != ""
      statements << RDF::Statement.new( uri, Vocabulary::DISCOGS.contactInformation, RDF::Literal.new(@address) )
    end
    
    if @parent != nil
      #clean_parent_name = Util.clean_escape(@parent)
      parent_uri = Label.create_uri( @parent )
      statements << RDF::Statement.new( uri, Vocabulary::DCTERMS.isPartOf, RDF::URI.new(parent_uri) )
    end
    
    return statements    
  end
          
  def Label.create_uri(name)
    slug = Util.slug(name)
    return Util.canonicalize("/label/#{ CGI::escape(slug) }")
  end
  
end