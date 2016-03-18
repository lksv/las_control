## LAS control

### Elastic search

Create index (or recreate index):

     Document.__elasticsearch__.create_index! force: true
     Document.__elasticsearch__.refresh_index!

Import Document records:

     bundle exec rake environment elasticsearch:import:model CLASS='Document'

Run this command to display usage instructions:

     bundle exec rake -D elasticsearch


Remove all elasticsearch data:

     curl -XDELETE 'http://localhost:9200/_all'

Setup low memory limits. See https://gist.github.com/dominicsayers/8319752 It is
recommaned to:

/etc/security/limits.conf

     elasticsearch hard memlock 100000

/etc/default/elasticsearch

     ES_HEAP_SIZE=128m
     MAX_LOCKED_MEMORY=100000
     ES_JAVA_OPTS=-server

/etc/elasticsearch/elasticsearch.yml

     index.number_of_shards: 1
     index.number_of_replicas: 0


### tre-ruby gem

You need to install this packages first:

     sudo apt-get install tre-agrep libtre5 libtre-dev
