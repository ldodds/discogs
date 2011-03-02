require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'pho'

BASE_DIR="~/data"

DISCOGS_DIR="#{BASE_DIR}/discogs"
DISCOGS_CACHE_DIR="#{DISCOGS_DIR}/cache"
DISCOGS_DATA_DIR="#{DISCOGS_DIR}/data"

STATIC_DATA_DIR="etc/static"

CLEAN.include ["#{DISCOGS_DATA_DIR}/*.nt", "#{DISCOGS_DATA_DIR}/*.ok", "#{DISCOGS_DATA_DIR}/*.fail", 
               "#{STATIC_DATA_DIR}/*.ok", "#{STATIC_DATA_DIR}/*.fail"]

Rake::TestTask.new do |test|
  test.test_files = FileList['tests/tc_*.rb']
end

#Download the export files for a specific data
task :download, :export_date do |t,args|
  if args.export_date == nil
    raise "No export date defined, e.g. rake download[20090701]"
  end
  sh %{curl -o #{DISCOGS_CACHE_DIR}/discogs_#{args.export_date}_labels.xml.gz http://www.discogs.com/data/discogs_#{args.export_date}_labels.xml.gz}  
  sh %{curl -o #{DISCOGS_CACHE_DIR}/discogs_#{args.export_date}_artists.xml.gz http://www.discogs.com/data/discogs_#{args.export_date}_artists.xml.gz}
  sh %{curl -o #{DISCOGS_CACHE_DIR}/discogs_#{args.export_date}_releases.xml.gz http://www.discogs.com/data/discogs_#{args.export_date}_releases.xml.gz}
  sh %{gunzip #{DISCOGS_CACHE_DIR}/*.gz }
end

#Split out first 1000 artists, labels, releases
task :split => [:split_labels, :split_artists, :split_releases]  

task :split_labels do
 sh %{ruby bin/split.rb #{DISCOGS_CACHE_DIR} label }
end

task :split_artists do
 sh %{ruby bin/split.rb #{DISCOGS_CACHE_DIR} artist }
end

task :split_releases do
 sh %{ruby bin/split.rb #{DISCOGS_CACHE_DIR} release }
end

task :convert_artists do
  sh %{ruby bin/convert_artists.rb #{DISCOGS_CACHE_DIR} #{DISCOGS_DATA_DIR} }  
end

task :convert_labels do
  sh %{ruby bin/convert_labels.rb #{DISCOGS_CACHE_DIR} #{DISCOGS_DATA_DIR} }  
end

task :convert_releases, :skip do |t,args| 
 sh %{ruby bin/convert_releases.rb #{DISCOGS_CACHE_DIR} #{DISCOGS_DATA_DIR} #{args.skip} }    
end

task :convert => [:convert_artists, :convert_labels, :convert_releases]

#Convert to ntriples  
task :ntriples do
  Dir.glob("#{STATIC_DATA_DIR}/*.rdf").each do |src|
    sh %{rapper -o ntriples #{src} >data/#{File.basename(src, ".rdf")}.nt}
  end
  FileUtils.cp("#{STATIC_DATA_DIR}/bbc-links.nt", "data/bbc-links.nt")
end

task :package do
  sh %{gzip data/*} 
end

#task :enrich_bbc_myspace do
#   discogs = Pho::Sparql::SparqlClient.new("http://api.talis.com/stores/bbc-backstage/services/sparql")
#   enricher = Pho::Enrichment::StoreEnricher.new(STORE, discogs)
#   locator_query = <<-EOL
#   PREFIX mo: <http://purl.org/ontology/mo/>
#   SELECT ?artist ?myspace WHERE {
#       ?artist mo:myspace ?myspace.
#   }
#   EOL
#         
#   enrichment = <<-EOL
#   PREFIX mo: <http://purl.org/ontology/mo/>
#   PREFIX po: <http://purl.org/ontology/po/>
#   PREFIX owl: <http://www.w3.org/2002/07/owl#>
#   CONSTRUCT {
#      ?artist owl:sameAs ?bbcArtist.
#      ?artist owl:sameAs ?dbpedia.
#      ?artist mo:musicbrainz ?mb.
#      ?artist mo:wikipedia ?wikipedia.
#   }
#   WHERE {
#     ?bbcArtist mo:myspace ?myspace.
#     OPTIONAL {
#       ?bbcArtist owl:sameAs ?dbpedia.
#       ?bbcArtist mo:wikipedia ?wikipedia.
#     }
#     OPTIONAL {
#       ?bbcArtist mo:musicbrainz ?mb.
#     }
#   }
#   EOL
#   enricher.enrich(locator_query, enrichment) do |source,resp|
#     if source == :query
#       puts "Enrichment query returned #{resp.status}"
#     else
#       puts "Store returned #{resp.status} when storing data"
#     end      
#   end
#end
