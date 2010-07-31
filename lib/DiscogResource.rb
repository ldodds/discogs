require "libxml"

class DiscogResource
  
  attr_reader :images
  
  def initialize(string)
    
    parser = LibXML::XML::Parser.string(string)
    doc = parser.parse
    @root = doc.root
    #puts @root
    
    @images = Array.new
    images = @root.find_first("images")
    if images != nil
      images.find("image").each do |image|
         @images << image.attributes 
      end      
    end
    
  end
     
  def get_optional_tag(tagname, clean=true)
    tag = @root.find_first(tagname)
    if tag != nil && tag.first.content != nil
      if clean
        return Util.clean_escape( tag.first.content )
      else
        return tag.first.content
      end        
    end    
    return nil
    
  end  
  
  def dump_image(image, label=nil, depicts=nil)
    statements = Array.new
    uri = RDF::URI.new( image["uri"] )
    exif = RDF::Vocabulary.new( "http://www.w3.org/2003/12/exif/ns#" )
    
    statements << RDF::Statement.new( uri, RDF.type, Vocabulary::FOAF.Image )
    statements << RDF::Statement.new( uri, exif.height, RDF::Literal.new( image["height"] ) )
    statements << RDF::Statement.new( uri, exif.width, RDF::Literal.new( image["width"] ))
    if label != nil
      statements << RDF::Statement.new( uri, RDF::RDFS.label, RDF::Literal.new( label ) )
    end
    if depicts != nil
      statements << RDF::Statement.new( uri, Vocabulary::FOAF.depicts, RDF::Literal.new( depicts ) )
    end
    statements << RDF::Statement.new( uri, Vocabulary::FOAF.thumbnail, RDF::URI.new( image["uri150"] ))
    return statements    
  end
  
end