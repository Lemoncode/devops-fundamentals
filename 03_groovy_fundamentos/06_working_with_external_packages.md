# Working with External Packages

At this point, you've got a decent grounding and what you generally create yourself in terms of scripts in Groovy. But there's a missing piece, the process of interacting with external packages in this day and age, if you gotta write everything yourself, a scripting language is mostly useless. 

We need to have the capability to leverage the work that others have done in rooting through the details of version control, working with the file system and, above all, the internals of Jenkins. 

* External packages
* Leveraging the work and creativity of others

The reality is that you get some external packages automatically with groovy, whether or not you can truly call them external when they're always included, you can argue about, but every base groovy script imports the following packages. 

| java.io.* | java.lang.* | java.math.BigDecimal | java.math.BigInteger |
|:---------:|:-----------:|----------------------|----------------------|
|  java.net |  java.util  |     groovy.lang.*    |     groovy.util.*    |


So this is the functional equivalent of having the following statements at the top of your script file. 

```groovy
import java.lang.*
import java.util.*
import java.io.*
import java.net.*
import groovy.lang.*
import groovy.util.*
import java.math.BigInteger
import java.math.BigDecimal
```

You almost always end up needing a bunch of these. You saw early how the very second we started dealing with real numbers, we needed big decimal, and here we are in general when you need to start dealing with libraries outside of these defaults, you bring them into the context of the script with an import statement.

# Demo: Working with External Packages

Create the following file [06_working_with_external_packages.groovy](playground/06_working_with_external_packages.groovy)

```groovy
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
```

If we execute this now we get the following message: `3: unable to resolve class JsonSlurper`

```diff
+import groovy.json.JsonSlurper
+
String filePath = "/home/groovy/scripts/chef.json";
...
```