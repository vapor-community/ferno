# Ferno 🔥

Ferno allows you to easily connect your Vapor project with your Firebase realtime database. It is built with the brand new Vapor 3. It gives you a nice and clean interface to interact with the Firebase Realtime REST API. It will automatically turn the response into your class/struct! 

### Prerequisites
You will need:
- Vapor 3.0+

### Installing

In your Package.swift file, add the line

```swift
.package(url: "https://github.com/AAAstorga/firebase-provider.git", from: "0.1.0")
```
Also make sure you add `Ferno` as a dependency

```swift
dependencies: ["Vapor", ..., "Ferno"]
```

## Setup

1. Ferno uses an access token to read and write to your database. First we will need to get your service account information.

    * Log into the Firebase console
    * Click the settings gear next to `Project Overview`
    * Select `Project settings`
    * Select the `SERVICE ACCOUNTS` tab
    * Click the button at the bottom that says `GENERATE NEW PRIVATE KEY`
    * This will download a `.json` file. You will now have access to the email and private key. You will pass those into the initialize during the next step.

2. Register `Ferno` as a Provider. This is usually done in `configure.swift`

```swift
let fernoConfig = FernoConfig(basePath: "database-url", email: "service-account-email", privateKey: "private-key")
services.register(fernoConfig)
try services.register(FernoProvider())
```

## Parameters
There are some custom parameters to pass into functions. I want to go over all the parameters you will need to know.

### [FernoQuery]
In GET requests, you might want to query on your data. This is what `[FernoQuery]` is for.

`FernoQuery` is an enum with:
   1. `case shallow(Bool)`
   2. `case orderBy(FernoValue)`
   3. `case limitToFirst(FernoValue)`
   4. `case limitToLast(FernoValue)`
   5. `case startAt(FernoValue)`
   6. `case endAt(FernoValue)`
   7. `case equalTo(FernoValue)`
   
These are all the possible queries that are allowed on Firebase according to the [docs](https://firebase.google.com/docs/reference/rest/database/#section-query-parameters)

#### NOTES on [FernoQuery]
-  `shallow(Bool)` cannot be mixed with any other query parameters.
- you usually use `orderBy(FernoValue)` in conjunction with enums `3-7`
- using `orderBy(FernoValue)` alone will just order the data returned

#### FernoValue
You will notice most cases in `FernoQuery` have a value of `FernoValue`.
`FernoValue` is just a wrapper for `Bool, String, Int, Double, Float`. So you can just do `.startAt(5)` and everything will work.

#### Examples of [FernoQuery]
Just using shallow: 
```swift
[.shallow(true)]
```
Filter data to only return data that matches `"age": 21`:
```swift
[.orderBy("age"), .equalTo(21)]
```

Just orderBy(returns data in ascending order):
```swift
[.orderBy("age")]
```
   
## Usage
There are 6 functions that allow you to interact with your Firebase realtime database.

### GET
There are two functions that allow you get your data.
   ```swift
   client.ferno.retrieve(req: Request, queryItems: [FernoQuery], appendedPath: [String])
   ```
   ```swift
   client.ferno.retrieveMany(req: Request, queryItems: [FernoQuery], appendedPath: [String])
   ```
The only difference between `retrieve` and `retrieveMany` is the return type.
- `retrive` returns -> `F` where `F` is of type `Decodable`
- `retrieveMany` returns -> `[String: F]` where `F` is of type `Decodable` and `String` is the key

#### Example
   1. Define the value you want the data converted. 
   ```swift
   struct Developer: Content {
      var name: String
      var favLanguage: String
      var age: Int
   }
   ```
   2. Make the request. Make sure you set the type of the response so Ferno knows what to convert.
   ```swift
   let developers: Future<[String: Developer]> = try client.ferno.retrieveMany(req: request, queryItems: [], appendedPath: ["developers"])
   
   let developer: Future<Developer> = try client.ferno.retrieve(req: request, queryItems: [], appendedPath: ["developers", "dev1"])
   ```
   
### POST
Used to create a new entry in your database
```swift
 client.ferno.create(req: Request, appendedPath: [String], body: T) -> Future<FernoChild>
```
- `body: T` is of type `Content`.
- `FernoChild` is a struct:
   ```swift
   struct FernoChild: Content {
   var name: String
   ```
- `FernoChild` is returned, because the API request returns the key from the newly created child.

#### Example
   ```swift
   let newDeveloper = Developer(name: "Elon", favLanguage: "Python", age: 46) //conforms to Content
   let newDeveloperKey: Future<FernoChild> = try client.ferno.create(req: request, appendedPath: ["developers"], body: newDeveloper)
   ```

### DELETE
Used to delete an entry in your database
```swift
 client.ferno.delete(req: Request, appendedPath: [String]) -> Future<Bool>
```
- the delete method will return a boolean depending on if the delete was successful

#### Example
   ```swift
   let successfulDelete: Future<Bool> = try client.ferno.delete(req: request, appendedPath: ["developers", "dev-1"])
   ```

### PATCH
update values at a specific location, but omitted values won't get removed
```swift
 client.ferno.update(req: Request, appendedPath: [String], body: T -> Future<T>
```
- the update method will return the body

### Example
   ```swift
   struct UpdateDeveloperName: Content {
   var name: String
   }
   let newDeveloperName = UpdateDeveloperName(name: "Kimbal") //conforms to Content
   let updatedDeveloperName: Future<UpdateDeveloperName> = try client.ferno.update(req: request, appendedPath: ["developers", newDeveloperKey.name], body: newDeveloper) //newDeveloperKey.name comes from the create method
   ```

### PUT
overwrite the current location with data you are passing in
```swift
 client.ferno.overwrite(req: Request, appendedPath: [String], body: T -> Future<T>
```

#### Example
   ```swift
   struct LeadDeveloper: Content {
   var name: String
   var company: String
   var age: Int
   }
   let leadDeveloper = LeadDeveloper(name: "Ashley", company: "Bio-Fit", age: 20)
   let leadDevResponse: Future<LeadDeveloper> = try client.ferno.overwrite(req: request, appendedPath: ["developers", newDeveloperKey.name], body: leadDeveloper)
   ```

## Testing

Currently, tests were written using an actual dummy Firebase realtime database. If you want to run all of the tests, you will need to create a dummy Firebase realtime database.

### Testing Setup

You need to go to `Application+Testing.swift` and fill in the missing values based on your Firebase service account. Then you will be able to run tests.

## Authors

* **Austin Astorga** - *Main developer* - [My Github](https://github.com/aaastorga)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Vapor Discord (for helping me with all my issues <3)
* Stripe Provider as a great template! [stripe-provider](https://github.com/vapor-community/stripe-provider)

