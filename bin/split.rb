# Split up an XML file. Useful for debugging
# ARGV[0] -- cache dir
# ARGV[1] -- name

Dir.chdir( "#{ARGV[0]}" )

Dir.mkdir("#{ARGV[0]}/#{ARGV[1]}s")

files = Dir.glob("discogs_*_#{ARGV[1]}s.xml")
if files.length() == 0
  puts "Unable to find #{ARGV[1]}s file"
  exit(1)
end

f = File.new(files[0])
count = 1

out = File.new( "#{ARGV[0]}/#{ARGV[1]}s/#{count}.xml", "w")
f.each do |line|        
    if line.match("<\/#{ARGV[1]}>$")
      out.puts(line)
      count += 1
      exit if count > 1000
      out = File.new( "#{ARGV[0]}/#{ARGV[1]}s/#{count}.xml", "w")
    else
      out.puts(line)  
    end  
end