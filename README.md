# Quantities

## Getting Started

When you create a domain model class, 
carefully when you have some quantitative data.
How do you represent their unit of measurement?

Considers these two examples.

### The Car Example

```C#
public class Car {
  public string Name { get; set; }
  public int Seats { get; set; }
  public int Length { get; set; }
  public double FuelCapacity { get; set; }
  public double CargoVolume { get; set; }
}
```

Name   | Seats | Length | Max Speed | Fuel Capacity | Cargo Volume
------ | ----: | -----: | --------: | ------------: | -----------:
Car A  | 5     | 4889   | 220       | 70.0          | 0.447
Car B  | 5     | 4848   | 220       | 64.0          | 0.436

Except *Seats* that already is the unit itself.
What are the unit of measurement of remaining values?

### The Tile Example

```C#
public class Tile {
  public string Name { get; set; }
  public double Width { get; set; }
  public double Length { get; set; }
  public int UnitsInStock { get; set; }
}
```

Name   | Width | Length | UnitsInStock 
------ | ----: | -----: | -----------: 
Tile A | 8     | 10     | 1200         
Tile B | 60    | 120    | 900          
 
While Tile A dimension is in inches, but Tile B is in centimeters.

## How to solve

1. **I know it**      
You just have only the amount data and omitted unit of measurement at all. 
You believe that you and every parties already know it
and will not change it.
You believe that it is totally managed 
and being used only by you.  
**Con:** It is not standardized and data is considerably incomplete.
Incomplete data will useless in future.
 
2. **I use standard unit**  
You use meters for length and kilograms for mass as specified 
in IS system.  
**Con:** It does not know how to represent again in its origin unit.
It is standardized now, but still incomplete.

3. **I put the unit in property name**  
You use *WidthMeters* or *WidthMillimeters*, 
so everybody know it!  
**Con:**  It is just a name. 
You cannot easily use it programmatically.
So you have to hard coding to calculate cubic meters
from some meters and some millimeters data.

4. **I use separate property for unit**  
You have a separate property for unit. 
So you add *WidthUnit* property for *Width*
and *WeightUnit* property for *Weight*.  
**Con:** You separate two data of one thing. 
So you have to know to use them together yourself in OOP.
That is some kind of overhead.

5. **I create a wrapper property for this**  
You use one of above solutions and create [NotMapped] property
that implements intelligent Quantity.
 

## The Quantities Library

The Quantities library use object-oriented approach intensively 
and highly inspired by the book Enterprise Patterns and MDA.

1. **Quantity = Amount + Unit**  
We can use just `Length` for the amount and unit of that quantity. 
So it is full self-descriptive and you can mix several units. (see Tiles Example)

2. **Quantity has Origin Unit**  
Quantity can be presented and converted to other unit 
but it still remember its own origin unit. (first assigned unit during creation of quantity)

3. **It can be used with Entity Framework**  
When we add the box to database then retrive it back, 
all quantities still be the same. Nothing lost, nothing changed.


## Explore

1. Let's considers the following code.  
   This code presents how to construct Length and Mass in 3 different ways.

  ```C#
  using GreatFriends.Quantities;
  using static System.Console;
  
  // Create object with quantities.
  var box = new Box {
              Code   = "B-1707",
              Width  = new Length(4.7, LengthUnit.Centimeters)), // Length
              Length = new Length(4.7, LengthUnit.Centimeters)),
              Height = Length.FromMeters(0.11),
              Weight = 9.Grams() // Mass
            };
  ``` 

2. `Length` and `Mass` are derived classes of `Quantity` and has two properties, 
   *Amount* (double by default) and *Unit* (`Unit`).
  
  ```C#
  // Explore and printing out
  WriteLine($"a) {box.Width.Amount:n2} {box.Width.Unit}"); // "a) 4.7 cm."
  WriteLine($"b) {box.Width}");                            // "b) 4.7 cm."
  WriteLine($"c) {box.Height}");                           // "c) 0.11 m."
  WriteLine($"d) {box.Height.ToCentimeters()}");           // "d) 11 cm."
  ```

3. If you want other than `double`, you can specify it this way.

  ```C#
  var length = 4889.Millimeters<int>();
  var maxSpeed = new Speed<float>(220, SpeedUnit.KilometersPerHour);
  ```

4. It is guaranteed to be saved and retrieve back from database through Entity Framework
  with no data loss. It still know its *original unit*.
  
  ```C#
  // Add it to database via Entity Framework
  db.Boxes.Add(box);
  db.SaveChanges();
  
  // Retrieve back from database
  using(var db2 = new Db()) {
    var box2 = db2.First();
    WriteLine(box2.Width);       // "4.7 cm."
    WriteLine(box2.Height);      // "0.11 m."
  }
  ```

5. Quantity can be manipulated with basic math operations 
  such as addition, subtraction, multiplication, and division.
  
  ```C#
  // Modify quantity
  var salt = new Mass(23, MassUnit.Grams); // 23 g.
  salt = salt * 2;                     // 46 g.
  salt += 500.Milligrams();            // 46.5 g.
  
  WriteLine(salt); // "46.5 g."
  WriteLine(salt.ToMilligrams("n2")); // "46,500 mg."
  
  Length a = 4.Inches();
  Length b = 20.Inches();
  Length c = (a + b).ToFeet(); // 2 ft. 
  ```

6. It also supports localization.
  
  ```C#
  // Localization
  var th = new CultureInfo("th-TH");
  WriteLine(salt.ToString(th)); // "46.5 ก."
  ```

7. Code can be simplified by using Settings.
  
  ```C#
  // Settings
  Quantity.Settings.Culture = new CultureInfo("en-US");
  Quantity.Settings.Amount.Format = "n2";
  Quantity.Settings.Unit.UseAbbreviation = false;
  
  WriteLine(salt); // "46.50 grams"
  ```


**Note** All text and code in README.md still under development and design.
 Everything can be changed.