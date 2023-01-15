NEXT_VERSION=$(cat version.txt | awk -F. -v OFS=. '{$NF += 1 ; print}')
echo $NEXT_VERSION

echo $NEXT_VERSION > version.txt

s3cmd sync ./ s3://${APP_BUCKET}


