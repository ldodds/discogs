module Util
      
  def Util.escape_ntriples(s)
    escaped = s.dup
    escaped.gsub!(/["]/, "\\\\\"")
    escaped.gsub!("\n", " ")
    escaped.gsub!("\r", " ")
    escaped.gsub!("\\", "\\\\")
    return escaped
  end
      
  #Util code for cleaning up whitespace, newlines, etc
  def Util.clean_ws(s)
    cleaned = s.gsub(/^\r\n/, "")
    cleaned.gsub!(/\n/, " ")    
    cleaned.gsub!(/\s{2,}/, " ")
    cleaned.gsub!(/^\s/, "")
    
    illegal = /\x00|\x01|\x02|\x03|\x04|\x05|\x06|\x07|\x08|\x0B|
    \x0C|\x0E|\x0F|\x10|\x11|\x12|\x13|\x14|\x15|\x16|\x17|\x18|\x19|\x1A|
    \x1B|\x1C|\x1D|\x1E|\x1F/
    
    cleaned.gsub!(illegal, " ")    
    if cleaned == "" or cleaned == " "
      return nil
    end
    return cleaned
  end  
  
  def Util.slug(s)
    normalized = s.downcase
    if normalized.end_with?(", the")
       normalized = normalized.gsub(", the", "")
       normalized = "the-" + normalized  
    end
    
    normalized.gsub!(/\s+/, "-")
    normalized.gsub!(/\(|\)/, "")

    normalized.gsub!(/%/, "")        
    normalized.gsub!(/,/, "")
    normalized.gsub! /\./, ""              
    normalized.gsub! /&/, "and"    
    normalized.gsub! /\?/, ""
    normalized.gsub! /\=/, ""
    normalized.gsub! /\[/, ""
    normalized.gsub! /\{/, ""
    normalized.gsub! /\]/, ""
    normalized.gsub! /\}/, ""
    normalized.gsub! /"/, ""    
    normalized.gsub! /'/, ""
    normalized.gsub! /|/, ""
    normalized.gsub! /!/, ""
    normalized.gsub! /:/, ""
    
    return normalized    
  end
   

  def Util.escape_xml(s)
    if s == nil
      return s
    end
    
    escaped = s.dup
    
    escaped.gsub!("&", "&amp;")
    escaped.gsub!("<", "&lt;")
    escaped.gsub!(">", "&gt;")
            
    return escaped
    
  end

  def Util.clean_url(url)
     if /http\:www/.match(url)
       url = url.gsub("http:www", "http://www")
     end
     if /http\:\/www/.match(url)
       url = url.gsub("http:/www", "http://www")
     end     
     if url.end_with?(",")
       url = url.gsub(",", "")
     end
     url = url.strip
     return url    
  end
  
  def Util.clean_escape(s)
    return escape_xml( clean_ws(s) ) 
  end  
    
  def Util.canonicalize(path)
    if path.start_with?("http")
      return path
    end  
    return "http://discogs.dataincubator.org#{path}"
  end
      
end