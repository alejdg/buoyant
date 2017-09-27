trap "docker-compose down" EXIT
docker-compose up -d ubuntu-xenial && docker-compose exec ubuntu-xenial /bin/bash
