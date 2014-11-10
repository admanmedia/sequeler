#!/bin/bash

sudo docker ps -a | grep sequeler > /dev/null
exists=$?

appdir=$(pwd)

if [ $exists -eq 0 ]; then
    echo 'Running Sequeler container...'
    sudo docker start sequeler > /dev/null
    sudo docker attach sequeler
else
    echo 'Creating Sequeler container...'
    sudo docker run -i -t -P --privileged --name sequeler -v $appdir:/src/sequeler rubencaro/elixir_mysql:0.1 /bin/bash
    if [ $? -ne 0 ]; then
      echo 'Could not run the container. Maybe the docker service is not running.'
    fi
fi
