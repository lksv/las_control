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
