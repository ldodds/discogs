$:.unshift File.join(File.dirname(__FILE__), "..", "lib")
require 'rubygems'
require 'pho'
require 'Release'
require 'Util'

#Where we're reading from
CACHE_DIR = ARGV[0]
#Where we're writing to
DATA_DIR = ARGV[1]
skip_records = 0 if ARGV[2] == nil
skip_records = ARGV[2].to_i if ARGV[2] != nil


Dir.chdir( CACHE_DIR )
release_files = Dir.glob("discogs_*_releases.xml")
if release_files.length() == 0
  puts "Unable to find releases file"
  exit(1)
end
releases = release_files[0]

file = File.new(releases)
release_chunk = ""
count = 0
processed = 0

if skip_records > 0
  filename = "#{ARGV[1]}/releases_#{skip_records}.nt"
else
  filename = "#{ARGV[1]}/releases_#{count}.nt"
end
writer = RDF::NTriples::Writer.new( File.new( filename , "w") )

file.each do |line|
    
    release_chunk << line 
    if line.match(/<\/release>$/)
      #completed release      
      count = count + 1
      
      #now do we process or skip?
      if skip_records == 0
        processed = processed + 1
        begin
         release = Release.new(release_chunk)
         statements = release.statements()
         statements.each do |stmt|
            writer << stmt
         end
         
        rescue StandardError => e
          puts e
          puts e.backtrace
          $stderr.puts release_chunk
        end
        
        #puts "Done process" if processed == 10000
        #break if processed == 10000
        
        if processed % 100000 == 0
          puts "Completed #{processed}"
          writer = RDF::NTriples::Writer.new( File.new( "#{ARGV[1]}/releases_#{count}.nt" , "w") )
        end
                      
      else
        skip_records = skip_records - 1
        puts "Skipped records" if skip_records == 0
      end
           
      release_chunk = ""             
    end
      
end
