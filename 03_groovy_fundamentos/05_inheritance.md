# Inheritance

We're going to go just one level deeper with this encapsulation and talk about inheritance. This is probably a little deeper than you'll end up working with scripting in Jenkins. But we've come this far and Groovy's implementation of inheritance tracks pretty well with the major languages. So I want to show you to have this as a tool in your toolbox. 

Groovy, absolutely supports traditional inheritance with interfaces just like Java. We're going to skip over that because the usual use case for inheritance is the finding a contract between things you control and things you may not, that just hasn't come into play very much in my working with Groovy and Jenkins. 

The other motive inheritance with inherited classes and in particular abstract glasses absolutely has. So we're gonna take a look at that to refresher object oriented memory. Abstract classes are classes which have implementation in them, actual code that executes and does work as opposed to interfaces, which just kind of describe the shape of the work and rely on the inheritor to supply the implementation. An abstract class per se cannot be instantied. You can think of an abstract class as an abstract idea which doesn't exist in any actual place but forms the basis for every actual class you're going to use. 

Nobody has the abstract idea of a car, they have an actual implementation of the abstract idea of a car, and all cars share those abstract ideals, though they may have tremendous variation. My 2008 Pontiac and a Tesla Roadster are tremendously different from each other, but they both share the abstract ideal of a car together, the value having abstract class that you can place what would be common between implementers, innit avoiding the programming evil of copy and paste.

* You might not need it
* Groovy supports interfaces
    - But the scripting case for interfaces is weaker
    - Not so for regular inheritance and abstract classes
* Abstract classe have implementation 
* Nobody has a car, _exactly_
* They have car _instances_ 
* Copy and paste is evil


Let's spin a bar demo scenario again. Let's say that global Maddox has an entertainment division and you want to represent the people involved in it. Some are artists somewhere, producers, and there's different things. They all have names, and importantly, they're all going to have the credentials that we work to create. The function for previously artists will have a song collection and producers will have a void produced method.

# Demo: Inheritance

Create the following file [05_inheritance.groovy](playground/05_inheritance.groovy)

We start from this code

```groovy
class User {
    String lastName;
    String firstName;

    public String UserName() {
        return getUserName(this.firstName, this.lastName);
    }

    String getUserName(String firstName, String lastName) {
        return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
    }
}

User[] users = [
    new User(firstName: "Ferra", lastName: "Adria"),
    new User(firstName: "Dani", lastName: "Garcia"),
    new User(firstName: "Jordi", lastName: "Cruz"),
    new User(firstName: "Joan", lastName: "Roca"),
    new User(firstName: "Martin", lastName: "Berasategi"),
];

users.each(user -> println("UserName is ${user.UserName()}"))

```

And we can run it as follows

```bash
$ docker run --rm -v $(pwd):/home/groovy/scripts -w /home/groovy/scripts groovy:latest groovy 05_inheritance.groovy 
UserName is bdylan
UserName is jlynne
UserName is rorbison
UserName is gharrison
UserName is tpetty
```

If we change the type of the class to `abstract` will get an exception, just as we expected

```diff
-class User {
+abstract class User {
    String lastName;
    String firstName;

    public String UserName() {
        return getUserName(this.firstName, this.lastName);
    }

    private String getUserName(String firstName, String lastName) {
        return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
    }
}
```

Let's create a couple of classes that extend from `User`

```groovy
abstract class User {
    String lastName;
    String firstName;

    public String UserName() {
        return getUserName(this.firstName, this.lastName);
    }

    private String getUserName(String firstName, String lastName) {
        return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
    }
}

/*diff*/
class FirstChef extends User {
    public String[] Dishes;
}

class Baker extends User {
    public void Bake() {}
}
/*diff*/

User[] users = [
    new User(firstName: "Ferra", lastName: "Adria"),
    new User(firstName: "Dani", lastName: "Garcia"),
    new User(firstName: "Jordi", lastName: "Cruz"),
    new User(firstName: "Joan", lastName: "Roca"),
    new User(firstName: "Martin", lastName: "Berasategi"),
];

users.each(user -> println("UserName is ${user.UserName()}"))

```

To solve our previous problem, we have to replace `User`

```diff
User[] users = [
-   new User(firstName: "Ferra", lastName: "Adria"),
-   new User(firstName: "Dani", lastName: "Garcia"),
-   new User(firstName: "Jordi", lastName: "Cruz"),
-   new User(firstName: "Joan", lastName: "Roca"),
-   new User(firstName: "Martin", lastName: "Berasategi"),
+   new FirstChef(firstName: "Ferra", lastName: "Adria"),
+   new FirstChef(firstName: "Dani", lastName: "Garcia"),
+   new FirstChef(firstName: "Jordi", lastName: "Cruz"),
+   new FirstChef(firstName: "Joan", lastName: "Roca"),
+   new FirstChef(firstName: "Martin", lastName: "Berasategi"),
];
```

For last, let's take adavantage of `polymorphism` here, let's see the final result

```groovy
abstract class User {
    String lastName;
    String firstName;

    public String UserName() {
        return getUserName(this.firstName, this.lastName);
    }

    String getUserName(String firstName, String lastName) {
        return firstName.substring(0, 1).toLowerCase() + lastName.toLowerCase();
    }
}

class FirstChef extends User {
    public String[] Dishes;
}

class Baker extends User {
    public void Bake() {
        /*diff*/
        println("Dessert ready");
        /*diff*/
    }
}

/*diff*/
User[] users = [
    new FirstChef(firstName: "Ferra", lastName: "Adria", Dishes: ["Locura"]),
    new FirstChef(firstName: "Dani", lastName: "Garcia", Dishes: ["Mojama"]),
    new FirstChef(firstName: "Jordi", lastName: "Cruz", Dishes: ["Rocas de Mar"]),
    new Baker(firstName: "Joan", lastName: "Roca"),
    new FirstChef(firstName: "Martin", lastName: "Berasategi", Dishes: ["Torrija"]),
];
/*diff*/

/*diff*/
users.each{
    user ->
    if (user instanceof FirstChef) {
        println("Username is ${user.UserName()}");
        user.Dishes.each(d -> println("${d}"));
    } else {
        user.Bake();
    }
}
/*diff*/

```