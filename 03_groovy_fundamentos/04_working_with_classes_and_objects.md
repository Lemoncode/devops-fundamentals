# Working with Classes and Objects

We've got our first base level of encapsulation going on now with subroutines. But like I said, you won't go for very long before you need the next level with all this stuff where we wrap our stuff up in classes. That example, We just looked at where we had to parallel lists of names. That was a prime thing to have wrapped up in a user class with two properties. That way, we don't have to worry about the arrays being different sizes or any other nonsense like that. Classes in Groovy are very similar to Java and C sharp. You declare class with the `class keyword` and declare instance properties pretty much exactly the same way. 

* Base level of encapsualtion
* Wrap your code in classes
* Parallel lists => object with two properties
* Very similar to Java or C#

```groovy
class User {
    // code and do stuff
}

User user = new User();
```

# Demo: Working with Classes and Objects

Create the following file [04_working_with_classe_and_objects.groovy](playground/04_working_with_classes_and_objects.groovy)

> Note: We start from the previous demo code.

```groovy
String getUserName(String firstName, String lastName) {
    return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
}

assert getUserName("Jaime", "Salas") == "jsalas" : "getUserName isn't working";

void printCredentials(cred) {
    println("UserName is ${cred}")
}

String[] firstNames = ["Ferra", "Dani", "Jordi", "Joan", "Martin"]
String[] lastNames = ["Adria", "Garcia", "Cruz", "Roca", "Berasategi"]

for (int i = 0; i < firstNames.size(); i++) {
   printCredentials(
       getUserName(firstNames[i], lastNames[i])
   );
}
```

```groovy
/*diff*/
class User {
    String lastName;
    String firstName;
}
/*diff*/

String getUserName(String firstName, String lastName) {
    return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
}

assert getUserName("Jaime", "Salas") == "jsalas" : "getUserName isn't working"

void printCredentials(cred) {
    println("UserName is ${cred}")
}

String[] firstNames = ["Ferra", "Dani", "Jordi", "Joan", "Martin"]
String[] lastNames = ["Adria", "Garcia", "Cruz", "Roca", "Berasategi"]

for (int i = 0; i < firstNames.size(); i++) {
    printCredentials(
        getUserName(firstNames[i], lastNames[i])
    );
}
```

Let's executed to verify that's legal code.

```bash
$ docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 04_working_with_classes_and_objects.groovy 
UserName is fadria
UserName is dgarcia
UserName is jcruz
UserName is jroca
UserName is mberasategi
```

Ok let's refactor our code

```diff
class User {
    String lastName;
    String firstName;
+
+   public String UserName() {
+       return getUserName(this.firstName, this.lastName);
+   }
+
+    private String getUserName(String firstName, String lastName) {
+        return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
+    }
}

-String getUserName(String firstName, String lastName) {
-    return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
-}

-assert getUserName("Jaime", "Salas") == "jsalas" : "getUserName isn't working"

-void printCredentials(cred) {
-    println("UserName is ${cred}")
-}

String[] firstNames = ["Ferra", "Dani", "Jordi", "Joan", "Martin"]
String[] lastNames = ["Adria", "Garcia", "Cruz", "Roca", "Berasategi"]

-for (int i = 0; i < firstNames.size(); i++) {
-    printCredentials(
-        getUserName(firstNames[i], lastNames[i])
-    );
-}
+
+for (int i = 0; i < firstNames.size(); i++) {
+   User u = new User(firstName: firstNames[i], lastName: lastNames[i]);
+   println("UserName is ${u.UserName()}")
+}

```

Let's check that is working. For last let's remove the two arrays and just create a unique array of users:

```diff
class User {
    String lastName;
    String firstName;

    public String UserName() {
        return getUserName(this.firstName, this.lastName);
    }

    private String getUserName(String firstName, String lastName) {
        return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
    }
}
-
-String[] firstNames = ["Ferra", "Dani", "Jordi", "Joan", "Martin"]
-String[] lastNames = ["Adria", "Garcia", "Cruz", "Roca", "Berasategi"]

+User[] users = [
+   new User(firstName: "Ferra", lastName: "Adria"),
+    new User(firstName: "Dani", lastName: "Garcia"),
+    new User(firstName: "Jordi", lastName: "Cruz"),
+    new User(firstName: "Joan", lastName: "Roca"),
+    new User(firstName: "Martin", lastName: "Berasategi"),
+];
-
-for (int i = 0; i < firstNames.size(); i++) {
-   User u = new User(firstName: firstNames[i], lastName: lastNames[i]);
-   println("UserName is ${u.UserName()}")
-}
+for (int i = 0; i < users.size(); i++) {
+   println("UserName is ${users[i].UserName()}")
+}
```