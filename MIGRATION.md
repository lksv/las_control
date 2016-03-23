## Copy plain text documents:

     ruby bin/copy_plain_text.rb > /tmp/plain_text_files.txt
     cd /home/lukas/projects/local_administration_map/las_control/public/system/dragonfly/development
     tar cvjf copy_plain_text.tar.bz2 -T /tmp/plain_text_files.txt
     scp copy_plain_text.tar.bz2 $DEST:


## Copy DB:

     echo $DB_PASSWORD
     pg_dump -Fc local_administration_model_development > /tmp/las.db.dump
     scp /tmp/las.db.dump $DEST:



## $DEST

     cd ~/las/local_administration_model/
     git pull
     cd las/las_control
     git pull

     source .env

     pg_restore -U deployer -d local_administration_model_production ~/las.db.dump

     cd $(rails runner 'puts Dragonfly.app.datastore.root_path')
     tar xjf ~/copy_plain_text.tar.bz2
     cd ~/las/las_control

     rails runner 'Document.__elasticsearch__.create_index! force: true'
     rails runner 'Document.__elasticsearch__.refresh_index!'
     bundle exec rake -D elasticsearch

     RAILS_ENV=production bin/rake assets:precompile
     kill $(cat tmp/pids/server.pid )
     rm -rf tmp/cache
     ./bin/spring stop
     nohup rails s -b 0.0.0.0 &
