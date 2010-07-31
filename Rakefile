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

#USER="ldodds"
#PASS="xxx"
#STORENAME="http://api.talis.com/stores/discogs"

CLEAN.include ["#{DISCOGS_DATA_DIR}/*.nt", "#{DISCOGS_DATA_DIR}/*.ok", "#{DISCOGS_DATA_DIR}/*.fail", 
               "#{STATIC_DATA_DIR}/*.ok", "#{STATIC_DATA_DIR}/*.fail"]

#STORE = Pho::Store.new(STORENAME, USER, PASS)

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

#task :upload_static do
#  collection = Pho::RDFCollection.new(STORE, STATIC_DATA_DIR)
#  puts "Uploading static data"
#  collection.store()
#  puts collection.summary()
#end
#
#task :upload_data do
#  collection = Pho::RDFCollection.new(STORE, DISCOGS_DATA_DIR)
#  puts "Uploading"
#  collection.store()
#  puts collection.summary()
#end
#
##Run SPARQL construct queries from etc/sparql to add in extra data
#task :infer do
#  
#  Dir.glob("etc/sparql/construct*.rq").each do |file|
#    print "Executing #{file}..."
#    query = File.new(file).read()
#    resp = Pho::Enrichment::StoreEnricher.infer(STORE, query)
#    puts resp.status
#  end
#    
#end

#task :publish => [:convert, :upload_static, :upload_data, :infer]

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
