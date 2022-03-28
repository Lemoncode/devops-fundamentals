import groovy.json.JsonSlurper;

String filePath = "/home/groovy/scripts/chef.json";

def jsonSlurper = new JsonSlurper()
ArrayList data = jsonSlurper.parse(new File(filePath));

println(data.getClass())

for (chef: data) {
    
    println(chef.name);
    for (restaurant: chef.restaurants) {
        println('\t' + restaurant.name)
    }
}