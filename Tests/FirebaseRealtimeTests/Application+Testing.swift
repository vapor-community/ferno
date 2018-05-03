//
//  Application+Testing.swift
//  Async
//
//  Created by Austin Astorga on 5/1/18.
//

import Foundation
import FirebaseRealtime
import Vapor

class CreateApp {
    static func makeApp() -> Application {
        let privateKey = """
-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDYYCKAA4AfPhRe\npdjKjQE9rnxa8wI73mzkgptXlarzTgQ3K8ZUVheAyhxjWVvQKOPSJ6GVMjRvz3kr\ntQt1y4zQF6aleFFc1e8fVkUUvQtZh1S1OtUaDYus727ixOdzPAV9k77pg34m0CWk\n3aOKEFh5p9Y9sbTu/HJqMkv7oF+EO8ArrkMBnv4ulG4OpSRLSykbwTgoWD8SLSu4\nFKtn8uBM0tOg1hZwqHbM04pw2d1p97i62r89N4Txjj1T2IV+ZBjo+Jxj1EBOqSTW\nD1Ug7KaeAZr2lo/WQ8O8V+hu7miI3AvIjnALDe01gfTP+SmAHEUszWdRJiFKleSb\nPEJppUI/AgMBAAECggEAGq84cgB8g4iHaz4ZegQLvCH8VMcVZnFsN9OM+YSMEaIf\nI6KyvIyQLMzq1VccMJQVDJeLS41mfseKfQPAhxAfAebOIX1beLnVhKWCCChhnEf0\nABRiWuqCvZrFr70dgiOhKwyBMJE2ie4vm6EjMxAIU/CJRmXXwjAV+CzTHBQk03dv\nksGbDCRaNjOjlYgsKxb2MrMl/3I/wKYUqRWZFwUAThY3NJOgfRL5CGXamFqoqPuC\nU/hS2fVhOSDb3U0vu0muolRq1d66UEhHoPNhQRYSQnhxTDb4zIdjq93fnC7YVz0a\nw/pzXUGi4rwwJZbS0NPOVTEfpW6OdhgDUersVGMs+QKBgQDshhR3MVHHWwTbgDKe\nskr5uZI4dUzvlJEZ82XvnI9C7A44cknQ2XBx2imcy6scEznsFunpY751HDQo/dd5\nuOfKf55I9rtf8VV7xsSOAQajLUUeTy0QmJm8c0OYXGuZpX6/nNRL1Bvw9GH/JGeG\naZvmLdJprzV70qXxBm7CQovn/QKBgQDqMVSQHbtgMj08xGgOzRxlxJrbwyBzr87F\nDG/obLvTwm8mpizrn/Tw4D5fxU130E0KY7o5dJLBGMiENBnIR7oCf8QPILwAm7+A\nsG2aKhZTlGEFCub3zCYpxTa0yz2VdeKKGfjl4P4UkXrAbudNbmipzLBRsDqpT+hO\nEMnMJmWR6wKBgQDjl2keAFEmuUiFRmhvGDTY813mAclUR+sPw4v08vtPdAGDA0ZQ\nNsriYwDjpX8y9rUnnizarWXZHph6UTgEIo635fETWIeYnIqbHfqIgig24BrAPYOp\nko1sLqV+eH/5SqwaCPinNqTkSOP7NLaBOiIPbUwo8bVPPrT6pivxtUMWqQKBgQDj\ntPdN8TrBO9gC/81VpuVXpiQUTdN96JEZUxB0Y1T1fvXoFGdU6wCUPNUo9YRvXN+r\nnG/zcX9HtTsyIB55eBRKXcRaGS/zP3yiOek3nnh656i16HXOtnbc4l5gx8SnUCnm\nsX4qtesWQKWj+bF4vkOR5e4CX2GKQqHTVcuAbk0P5QKBgQDoh24Rw7HbnY6myqZb\nLcY4UNMNi/cZ7rFcV1H8nuH4/UEARhdjOlJ/P2OkFd/cA96sEVXFBZ/QueYsYygU\na/OBPHqrKbMvMrATe36K/d21DiylTSqLKY2e5EYg2dwVbGan87SnJqeAW0GNWzOD\n2C79fXL6YfYobrjdsUearcp/jw==\n-----END PRIVATE KEY-----\n
"""

        let config = Config.default()
        let env = try! Environment.detect()
        var services = Services.default()
        let firebaseConfig = FirebaseConfig(basePath: "https://fir-realtime-f7953.firebaseio.com", email: "firebase-adminsdk-vwhg9@fir-realtime-f7953.iam.gserviceaccount.com", privateKey: privateKey)
        services.register(firebaseConfig)
        try! services.register(FirebaseProvider())


        return try! Application(config: config, environment: env, services: services)
    }
}
