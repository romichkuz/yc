export $(cat .env | xargs)
export $(cat version.txt | xargs)

NEXT_VERSION=$(echo $APP_VERSION | awk -F. -v OFS=. '{$NF += 1 ; print}')
echo "APP_VERSION=${NEXT_VERSION}" > version.txt

APP_REPOSITORY=$(echo ${APP_REPOSITORY})
IMAGE_NAME=$(echo "${APP_REPOSITORY}:${NEXT_VERSION}")

echo $IMAGE_NAME
docker build -t $IMAGE_NAME . ;

docker push $IMAGE_NAME;

CONTAINER_ID=$(echo ${CONTAINER_ID})
YDB_ENDPOINT=$(echo ${YDB_ENDPOINT})
YDB_DATABASE=$(echo ${YDB_DATABASE})
SA_ID=$(echo ${SA_ID})


yc sls container revisions deploy \
    --container-id ${CONTAINER_ID} \
    --memory 512M \
    --cores 1 \
    --execution-timeout 5s \
    --concurrency 8 \
    --image "$IMAGE_NAME" \
    --environment  YDB_ENDPOINT=${YDB_ENDPOINT},YDB_DATABASE=${YDB_DATABASE} \
    --service-account-id ${SA_ID};