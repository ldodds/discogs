$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'rubygems'
require 'pho'
require 'Artist'
require 'Util'

#Where we're reading from
CACHE_DIR = ARGV[0]
#Where we're writing to
DATA_DIR = ARGV[1]

Dir.chdir( CACHE_DIR )
label_files = Dir.glob("discogs_*_artists.xml")
if label_files.length() == 0
  puts "Unable to find artists file"
  exit(1)
end
labels = label_files[0]

file = File.new(labels)
chunk = ""
count = 0
writer = RDF::NTriples::Writer.new( File.new("#{ARGV[1]}/artists_#{count}.nt", "w") )

file.each do |line|        
    chunk << line 
    if line.match(/<\/artist>$/)
      #completed artist      
      count = count + 1
      begin
       artist = Artist.new(chunk)
       statements = artist.statements()
       statements.each do |stmt|
          writer << stmt
       end
      rescue StandardError => e
        puts e
        puts e.backtrace
        $stderr.puts chunk
      end
      
      #break if count == 1000
      
      if count % 100000 == 0
        puts "Completed #{count}"
        writer = RDF::NTriples::Writer.new( File.new("#{ARGV[1]}/artists_#{count}.nt", "w") )        
      end
            
      chunk = ""
    end  
end