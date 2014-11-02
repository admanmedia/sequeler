#!/bin/bash

sudo docker ps -a | grep sequeler > /dev/null
exists=$?

appdir=$(pwd)

if [ $exists -eq 0 ]; then
    echo 'Sequeler container exists'
    sudo docker start sequeler > /dev/null
    sudo docker attach sequeler
else
    echo 'Sequeler container does not exist'
    sudo docker run -i -t -P --privileged --name sequeler -v $appdir:/src/sequeler rubencaro/elixir_mysql:0.1 /bin/bash
fi