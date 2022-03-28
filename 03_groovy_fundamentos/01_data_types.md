# Data Types

Obviously, in our script, we're dealing with a Number X equals five. Then we perform arithmetic on it, so we're dealing with numbers and math. Here, **Groovy** is an optionally typed language, which means that we can either work with the defines Java primitives, or we can let the groovy run time guess the type from the context, which it does pretty well. As third option, you can eliminate the type or death keyword entirely and simply declare the variable with no key word at all. 

* x is clearly a number
* An optionally typed language
* No type definition at all


When I need to work with the new scripting language, I want to know how to work with four essential data types. First strings, intagers, floats, and by that I mean numbers with decimal points and booleans . That's about 90% of my work with scripts historically, so that's what we'll focus on, here are our key words:

| Data Type | Groovy Keyword | Sample Data   |
|:---------:|:--------------:|---------------|
|  Strings  |     String     | "Jaime Salas" |
|  Integers |       int      |   0, 1, 2, 3  |
|   Floats  |      float     |    0.5, 3.8   |
|  Boolean  |     Boolean    |  true, false  |

# Demo: Data Types

Create the following file [01_groovy_data_types.groovy](playground/01_groovy_data_types.groovy)

```groovy
String name = "Joe Doe"
int courseCount = 14
float salary = 999999.99
Boolean isProgrammer = true

println name + " has created " + courseCount + " courses." // [1]
println name + " is a programmer? " + isProgrammer // [1]
println name + " wishes his salary was " + salary // [1]
```

1. Groovy converts the booleans and float into strings

And we can execute as follows

```bash
$ docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 01_groovy_data_types.groovy 
Joe Doe has created 14 courses.
Joe Doe is a programmer? true
Joe Doe wishes his salary was 1000000.0
```

Let's add a little difference

```diff
String name = "Joe Doe"
int courseCount = 14
float salary = 999999.99
Boolean isProgrammer = true

println name + " has created " + courseCount + " courses."
-println name + " is a programmer? " + isProgrammer
+println name + " is a programmer? " + isProgrammer.toString().capitalize()
println name + " wishes his salary was " + salary
```

```bash
$ docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 01_groovy_data_types.groovy 
Joe Doe has created 14 courses.
Joe Doe is a programmer? True
Joe Doe wishes his salary was 1000000.0
```

Notice that we have a problem on how Groovy converts the float into string, we can get fine grane control by using the built in format method for the string prototype

```diff
String name = "Joe Doe"
int courseCount = 14
float salary = 999999.99
Boolean isProgrammer = true

println name + " has created " + courseCount + " courses."
println name + " is a programmer? " + isProgrammer.toString().capitalize()
-println name + " wishes his salary was " + salary
+println name + " wishes his salary was \$" + String.format("%.2f", salary)
```

```bash
$ docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 01_groovy_data_types.groovy 
Joe Doe has created 14 courses.
Joe Doe is a programmer? True
Joe Doe wishes his salary was $1000000.00
```

Stills adding a penny to the salary, it's round up, to make our life more simple we can change the type:

```diff
String name = "Joe Doe"
int courseCount = 14
-float salary = 999999.99
+BigDecimal salary = 999999.99
Boolean isProgrammer = true

println name + " has created " + courseCount + " courses."
println name + " is a programmer? " + isProgrammer.toString().capitalize()
-println name + " wishes his salary was \$" + String.format("%.2f", salary)
+println name + " wishes his salary was \$" + salary
```

Just to point out that in Java we have line terminations `;`, Groovy works fine without them.

### Data Types and Syntax

* Optional "def" or explicit data type
* Loose typing? Meh
* Okay when the return value is crystal clear