# Control Structures

To do anything meaningful in our script, we need control structures, ways for the code to make decisions based on the values they're in. The most essential control structure is `if else` block in groovy. It looks just like it does in Java or C sharp for that. Better simple.

```groovy
if (isProgrammer) {
    println "He's a programmer, alright"
}
else {
    println "Not a programmer, tho"
}
```

It's the same for a loop 

```groovy
for (int i = 0; i < courseCount; i++) {
    println "Chris made course " + (i + 1) + "!!!"
}
```

And pretty much the same for a while loop. 

```groovy
int i = 0;

while (i < courseCount) {
    println "Chris made course " + (i + 1) + "!!!"
    i++
}
```

There is one loop that, while very similar to the Java Syntax, is different than C sharp before each or for in loop in the foreign loop, we define init aerator value in the array to iterate and separate them with a colon like so.  

```groovy
String[] singers = ["Bob", "George", "Jeff", "Roy", "Tom"]

for(String singer: singers) {
    println singer
}
```

We can shorthand this loop with the each method here were defining our iterator value as X in just printing it out. 

```groovy
singers.each(x -> println(x))
```

We can drill it down even further by using the keyword like so. 

```groovy
singers.each(println(it))
```

# Demo: Control Structures

Create the following file [02_control_structures.groovy](playground/02_control_structures.groovy)

```groovy
int courseCount = 14;
Boolean isProgrammer = true;
String[] singers = ["Bob", "George", "Jeff", "Roy", "Tom"]

if (isProgrammer) {
    println "He's a programmer"
}
else {
    println "not a programmer"
}

for (int i = 0; i < courseCount; i++) {
    println "Chris made course " + (i + 1) + "!!!"
}

for (String singer: singers) {
    println singer
}

singers.each(x -> println(x))
singers.each{println(it)}
```

And run it with

```bash
$ docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 02_control_structures.groovy 
He's a programmer
Chris made course 1!!!
Chris made course 2!!!
Chris made course 3!!!
Chris made course 4!!!
Chris made course 5!!!
Chris made course 6!!!
Chris made course 7!!!
Chris made course 8!!!
Chris made course 9!!!
Chris made course 10!!!
Chris made course 11!!!
Chris made course 12!!!
Chris made course 13!!!
Chris made course 14!!!
Bob
George
Jeff
Roy
Tom
Bob
George
Jeff
Roy
Tom
```