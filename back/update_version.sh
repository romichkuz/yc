export $(cat .env | xargs)
export $(cat version.txt | xargs)

NEXT_VERSION=$(echo $APP_VERSION | awk -F. -v OFS=. '{$NF += 1 ; print}')
echo "APP_VERSION=${NEXT_VERSION}" > version.txt

IMAGE_NAME=${APP_REPOSITORY}:$NEXT_VERSION

docker build -t $IMAGE_NAME . ;

# docker push
# yls deploy 