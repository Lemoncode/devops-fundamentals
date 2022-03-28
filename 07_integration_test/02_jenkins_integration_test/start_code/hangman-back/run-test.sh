echo "start running tests" 

docker-compose -f test-integration.yml up -d

echo "tests in progress"

docker wait test-integration

echo "clear resources"

docker-compose -f test-integration.yml down --rmi all -v