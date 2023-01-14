NEXT_VERSION=$(cat version.txt | awk -F. -v OFS=. '{$NF += 1 ; print}')
echo $NEXT_VERSION

#sync 
echo $NEXT_VERSION > version.txt

