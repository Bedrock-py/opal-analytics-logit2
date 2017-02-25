# Usage: install_in_docker.sh $ID
# $ID is populated if docker is started with this command from the bedrock-core directory:
#		docker build -t bedrock . && ID=$(docker run -p 81:81 -p 82:82 -d bedrock)

ID=$1

docker cp opal-analytics-logit2.tar.gz $ID:/opt/bedrock/package/
docker exec $ID tar -zxf /opt/bedrock/package/opal-analytics-logit2.tar.gz -C /opt/bedrock/package
docker exec $ID pip install -e /opt/bedrock/package/opal-analytics-logit2
docker exec $ID service apache2 reload

