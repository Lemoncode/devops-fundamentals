# Subroutines

You won't get very far with any scripting task before you'll want to compartmentalize your code into subroutines. Whether this is for reuse or simply for drawing a box around a piece of code to make it more comprehensible, in groovy and really in all of computer science, there are two types of subroutines. Functions and methods. 

Functions return a value. Methods do not. Some languages make a strong delineation between them, but groovy, like Java and C Sharp, simply defines a method as a function with avoid return type. 

Let's say that in our builds, we're going to need to generate some credentials sets generated from the user's names. We want to create a simple user name using the first letter of the first name plus the entirety of the last name, will sidestep the problem of uniqueness for the names, for now. that's our first function, one with a return value. 

Our second function will be a super simple function to output the credential to the console are void. Function will be super simple, but it might be useful as a first step towards a more sophisticated output that we be creating on down the line.

* Functions
* Methods
* Groovy, Java and C#: void return type
* A function to create credentials from a name

# Demo: Soubroutines

Create a new file [03_groovy_soubroutines](playground/03_soubroutines.groovy)

Let's start by a simple assertion 

```groovy
assert getUserName("Jaime", "Salas") == "jsalas" : "getUserName isn't working"
```

```groovy
/*diff*/
String getUserName(String firstName, String lastName) {
    return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
}
/*diff*/

assert getUserName("Jaime", "Salas") == "jsalas" : "getUserName isn't working"
```

We can run it with `docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 03_subroutines.groovy`, this returns __null__ indicating that the result is ok.

Print the return value to the console to make it a little bit cleaner

```diff
String getUserName(String firstName, String lastName) {
    return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
}

assert getUserName("Jaime", "Salas") == "jsalas" : "getUserName isn't working"

+println(getUserName("Jaime", "Salas"))
```

Now let's create a method that prints the credentials

```groovy
String getUserName(String firstName, String lastName) {
    return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
}

assert getUserName("Jaime", "Salas") == "jsalas" : "getUserName isn't working"

println(getUserName("Jaime", "Salas"))

/*diff*/
void printCredentials(cred) {
    println("UserName is ${cred}")
}

printCredentials(getUserName("Jaime", "Salas"))
/**/
```

After run it, we get

```bash
$ docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 03_soubroutines.groovy 
jsalas
UserName is jsalas
```

Let's modify this to work with arrays of names and lastnames

```diff
String getUserName(String firstName, String lastName) {
    return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
}

assert getUserName("Jaime", "Salas") == "jsalas" : "getUserName isn't working"

-println(getUserName("Jaime", "Salas"))

void printCredentials(cred) {
    println("UserName is ${cred}")
}

-printCredentials(getUserName("Jaime", "Salas"))

+String[] firstNames = ["Ferra", "Dani", "Jordi", "Joan", "Martin"]
+String[] lastNames = ["Adriá", "García", "Cruz", "Roca", "Berasategi"]
+
+for (int i = 0; i < firstNames.size(); i++) {
+   printCredentials(
+       getUserName(firstNames[i], lastNames[i])
+   );
+}
```

After run it, we get

```bash
$ docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 03_soubroutines.groovy 
UserName is fadriá
UserName is dgarcía
UserName is jcruz
UserName is jroca
UserName is mberasategi
```