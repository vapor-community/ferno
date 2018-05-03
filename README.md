# Ferno 🔥

Ferno allows you to easily connect your vapor project with your Firebase realtime database. It is built with the brand new Vapor 3. It gives you a nice and clean interface to interact with the Firebase Realtime REST API.
## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites
You will need:
- Vapor 3.0+

### Installing

In your Package.swift file, add the line

```swift
.package(url: "https://github.com/AAAstorga/firebase-provider.git", from: "1.0.0")
```
Also make sure you add `Ferno` as a dependency

```swift
dependencies: ["Vapor", ..., "Ferno"]
```

## Usage

1. Ferno uses an access token to read and write to your database. First we will need to get a your service account information.

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


## Testing

Some of the tests written use an actual dummy Firebase realtime database. If you want to run all of the tests, you will need to create a dummy Firebase realtime database. The rest of the tests use a fake client to mimic responses by Firebase.

### Testing Setup

#TODO Explain how to set up tests to run

```
Give an example
```

## Authors

* **Austin Astorga** - *Main developer* - [My Github](https://github.com/aaastorga)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Vapor Discord (for helping me with all my issues <3)
* Stripe Provider as a great template! [stripe-provider](https://github.com/vapor-community/stripe-provider)

