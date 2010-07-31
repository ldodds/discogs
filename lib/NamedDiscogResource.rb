require 'libxml'
require 'uri'
require 'cgi'
require 'Util'
require 'DiscogResource'

class NamedDiscogResource < DiscogResource
  
  attr_reader :raw_name, :name, :urls
  
  def initialize(string)
    super(string)
    
    name = @root.find_first("name").first    
    @raw_name = name.content
    #TODO literal?
    @name = Util.clean_escape( @raw_name )
    
    @urls = Array.new
    urls = @root.find_first("urls")
    if urls != nil
      urls.find("url").each do |url|
          if url.first && url.first.content != nil && url.first.content != ""
            href = Util.clean_ws(url.first.content)
            if href != nil
              #TODO: remove downcase as it was breaking wikipedia/dbpedia links              
              location = href.strip
              if !location.start_with?("http://")
                location = "http://#{location}"
              end
              @urls << location  
            end           
            
          end
      end      
    end
        
  end
  
end