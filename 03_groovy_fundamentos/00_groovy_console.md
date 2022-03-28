# The Groovy Console

The very first thing we need to work with any kind of development is something that validates and verifies that our code is behaving like we wanted. Otherwise our code is just literature. 

Our ultimate target for all of this is going to be Jenkins itself. And short of that, Jenkins has an internal, groovy console for validating scripts. But it's useful for us to have something even more lightweight than that. 

A groovy console entirely separate from Jenkins and from build engineering and everything a nice kiddie pool that we can get our feet with with in Groovy. The organization, which maintains groovy Apache, has just such a tool available for us at this [link](http://groovy-lang.org/download.html). This console is a job application, specifically a swing application, which is a groovy toolkit for Java. Let's take a look.

* Something to validate and verify our code
* Jenkins is the ultimate target
* A place to experiment

Alternative to local instalation we can use a [Docker container](https://hub.docker.com/_/groovy?tab=description)

```bash
docker run -it --rm groovy

# Running a Groovy script
docker run --rm -v "$PWD":/home/groovy/scripts -w /home/groovy/scripts groovy groovy <script> <script-args>
```

> Reference: https://groovy-lang.gitlab.io/101-scripts/docker/basico-en.html

Create `BasicDocker.groovy`

```groovy
println "------------------------------------------------------------------"
println "Hello"
System.getenv().each{
    println it
}
println "------------------------------------------------------------------"
```

Now from root folder where we created the file we can run 

```bash
docker run --rm -v "$PWD":/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy BasicDocker.groovy -a 
```

* The `-a` flag is to dump the system variables
* The `-w` working directory inside the container

# Demo: The Groovy Console

* Create `playground/00_groovy_console.groovy`

```groovy
def x = 5

x += 5

println x
assert x == 10
```

And then we can run it, as follows:

```bash
$ docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 00_groovy_console.groovy
$ 10
```

If we change the value of `x`

```diff
def x = 5

x += 5

println x
-assert x == 10
+assert x == 11
```

We can insert a message if the assertion doesn't pass

```diff
def x = 5

x += 5

println x
-assert x == 11
+assert x == 11: "Value was not eleven"
```

```bash
Jaimes-MacBook-Pro:playground jaimesalaszancada$ docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 00_groovy_console.groovy
10
Caught: java.lang.AssertionError: Value was not eleven. Expression: (x == 11). Values: x = 10
java.lang.AssertionError: Value was not eleven. Expression: (x == 11). Values: x = 10
        at 00_groovy_console.run(00_groovy_console.groovy:7)
```