# Quantities

## Getting Started

When you create a domain model class, 
carefully when you have some quantitative data.
How do you represent their unit of measurement?

Considers these two examples.

### The Cars Example

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

### The Tiles Example

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
 

From the **Cars Example**, *Seat* is already unit of measurement itself (how many seats). 
But *Length* is in **millimeters**. 
*MaxSpeed* is in **kilometers per hour**,
*FuelCapacity* is in **liters**, and *CargoVolume* is in **cubic meters**.

From the **Tiles Example**, *UnitsInStock* is already unit of measurement itself (how many units).
*Width* and *Length* mixed use of unit. *Tile A* is in **inches** 
but *Tile B* is in **centimeters**.
 

## Wrong ways to solve it

1. **I know it**      
You just have only the amount data and omitted unit of measurement at all. 
You believe that you and every parties already know it
and will not change it.
You believe that it is totally managed 
and being used only by you.  
**Con:** It is not standardized and data is considerably incomplete.
Incomeplete data will useless in future.
 
2. **I use standard unit**  
You use meters for length and kilograms for mass as specified 
in IS system.  
**Con:** It does not know how to represent again in its origin unit.
It is standardarized now, but still incomplete.

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

Let's considers the following code.
This code presents how to construct Length and Mass in 3 different ways.

```C#
using GreatFriends.Quantities;
using static System.Console;

// 1. Create object with quantities.
var box = new Box {
            Code   = "B-1707",
            Width  = new Length(4.7, Unit.Centimeters)), // Length
            Length = new Length(4.7, Unit.Centimeters)),
            Height = Length.FromMeters(0.11),
            Weight = 9.Grams() // Mass
          };
``` 

`Length` and `Mass` are derived class of `Quantity` and has two properties, 
*Amount* (decimal by default) and *Unit* (`Unit`).

```C#
// 2. Explore and printing out
WriteLine($"a) {box.Width.Amount:n2} {box.Width.Unit}"); // "a) 4.7 cm."
WriteLine($"b) {box.Width}");                            // "b) 4.7 cm."
WriteLine($"c) {box.Height}");                           // "c) 0.11 m."
WriteLine($"d) {box.Height.ToCentimeters()}");           // "d) 11 cm."
```

It is guaranteed to be saved and retrive back from database through Entity Framework
with no data loss. It still know its *origin unit*.

```C#
// 3. Add it to database via Entity Framework
db.Boxes.Add(box);
db.SaveChanges();

// 4. Retrieve back from database
using(var db = new Db()) {
  var box2 = db.First();
  WriteLine(box2.Width);       // "4.7 cm."
  WriteLine(box2.Height);      // "0.11 m."
}
```

Quantity can be manipulated with basic math operations 
such as addition, substraction, multiplication, and division.

```C#
// 5. Modify quantity
var salt = new Mass(23, Unit.Grams); // 23 g.
salt = salt * 2;                     // 46 g.
salt += 500.Milligrams();            // 46.5 g.

WriteLine(salt); // "46.5 g."
WriteLine(salt.ToMilligrams("n2")); // "46,500 mg."

Length a = 4.Inches();
Length b = 20.Inches();
Length c = (a + b).ToFeet(); // 2 ft. 
```

It also supports localization.

```C#
// 6. Localization
var th = new CultureInfo("th-TH");
WriteLine(salt.ToString(th)); // "46.5 ก."
```

Code can be simplified by use Settings.

```C#
// 7. Settings
Quantity.Settings.Culture = new CultureInfo("en-US");
Quantity.Settings.Amount.Format = "n2";
Quantity.Settings.Unit.UseAbbreviation = false;

WriteLine(salt); // "46.50 grams"
```


**Note** All text and code in README.md still under development and design.
 Everything can be changed.