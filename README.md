# work rails project

docker-compose run --service-ports web bash

rake db:migrate

rails s -b 0.0.0.0
