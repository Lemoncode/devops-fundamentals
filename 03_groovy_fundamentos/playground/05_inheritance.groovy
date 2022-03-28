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
        println("Dessert ready");
    }
}

User[] users = [
    new FirstChef(firstName: "Ferra", lastName: "Adria", Dishes: ["Locura"]),
    new FirstChef(firstName: "Dani", lastName: "Garcia", Dishes: ["Mojama"]),
    new FirstChef(firstName: "Jordi", lastName: "Cruz", Dishes: ["Rocas de Mar"]),
    new Baker(firstName: "Joan", lastName: "Roca"),
    new FirstChef(firstName: "Martin", lastName: "Berasategi", Dishes: ["Torrija"]),
];

users.each{
    user ->
    if (user instanceof FirstChef) {
        println("Username is ${user.UserName()}");
        user.Dishes.each(d -> println("${d}"));
    } else {
        user.Bake();
    }
}