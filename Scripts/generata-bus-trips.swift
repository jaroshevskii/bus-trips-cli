#!/usr/bin/swift
//
// BusTrips CLI
//

import Foundation

struct Route: Codable {
  let departure: String
  let arrival: String
}

struct Trip: Codable {
  let ticketPrice: Int
  let dateOfDeparture: TimeInterval
  let route: Route
  let availableSeatCount: Int
}

let numTrips = Int(CommandLine.arguments[1])!

let cities = ["New York", "London", "Paris", "Berlin", "Tokyo", "Sydney", "Moscow", "Beijing"]

var trips: [Trip] = []
for _ in 1...numTrips {
  let departure = cities.randomElement()!
  var arrival = cities.randomElement()!
  while arrival == departure {
    arrival = cities.randomElement()!
  }
  let route = Route(departure: departure, arrival: arrival)
  let ticketPrice = Int.random(in: 50...200)
  let dateOfDeparture = Date().addingTimeInterval(TimeInterval.random(in: 3600...86400*30)).timeIntervalSince1970
  let availableSeatCount = Int.random(in: 1...10)
  let trip = Trip(ticketPrice: ticketPrice, dateOfDeparture: dateOfDeparture, route: route, availableSeatCount: availableSeatCount)
  trips.append(trip)
}

let encoder = JSONEncoder()
encoder.outputFormatting = .prettyPrinted

guard let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first else {
  throw AddBusTripError.desktopDirectoryPathNotFound
}
let fileURL = desktopURL.appendingPathComponent("BusTrips.json")

do {
  let jsonData = try encoder.encode(["available": trips])
  if let jsonString = String(data: jsonData, encoding: .utf8) {
    let outputURL = URL(fileURLWithPath: fileURL.path)
    try jsonString.write(to: outputURL, atomically: true, encoding: .utf8)
    print("Done! Generated \(numTrips) trips and written to '\(fileURL.path)' file.")
  }
} catch {
  print(error.localizedDescription)
}

/// An error that can be thrown when working with `AddBusTrip`.
enum AddBusTripError: Error {
  case desktopDirectoryPathNotFound
}

extension AddBusTripError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .desktopDirectoryPathNotFound:
      return "Can't find the path to the desktop directory."
    }
  }
}
