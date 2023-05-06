//
// BusTrips CLI
//

import Foundation
import ArgumentParser

struct AddBusTrip: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "add",
    abstract: "Add a bus trip."
  )

  @Option(help: "The route of the bus trip. (format: Departure - Arrival)")
  var route: String

  @Option(help: "The date of departure of the bus trip. (format: \(Trip.dateFormat))")
  var date: String

  @Option(parsing: .unconditional, help: "Number of bus seats available for booking.")
  var seatCount: Int

  @Option(parsing: .unconditional, help: "The price of a bus ticket.")
  var price: Double

  func validate() throws {
    try validateRoute()
    try validateDate()
    try validateSeatCount()
    try validatePrice()
  }

  func validateRoute() throws {
    do {
      _ = try Route(route)
    } catch RouteError.emptyField {
      throw ValidationError("The route cannot contain empty points.")
    } catch RouteError.sameDepartureAndArrival {
      throw ValidationError("Departure and arrival points cannot be the same.")
    } catch RouteError.invalidFormat {
      throw ValidationError("The route must contain departure and arrival points separated by '\(Route.separator)'.")
    }
  }

  func validateDate() throws {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = Trip.dateFormat

    guard let date = dateFormatter.date(from: date) else {
      throw ValidationError("The date should be in the format '\(Trip.dateFormat)'.")
    }
    guard date > .now else {
      throw ValidationError("The departure date must be in the future.")
    }
  }

  func validateSeatCount() throws {
    guard seatCount >= 1 else {
      throw ValidationError("There must be at least one free seat.")
    }
  }

  func validatePrice() throws {
    guard price >= 0 else {
      throw ValidationError("The ticket price cannot be negative.")
    }
  }

  func run() throws {
    guard let desktopURL = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first else {
      throw AddBusTripError.desktopDirectoryPathNotFound
    }
    let fileURL = desktopURL.appendingPathComponent("BusTrips.json")

    var busTrips = [String: Set<Trip>]()

    if FileManager.default.fileExists(atPath: fileURL.path) {
      let data = try Data(contentsOf: fileURL)
      let decoder = JSONDecoder()
      busTrips = try decoder.decode([String: Set<Trip>].self, from: data)
    }
    
    let formatter = DateFormatter()
    formatter.dateFormat = Trip.dateFormat

    let newTrip = Trip(
      route: try! Route(route),
      dateOfDeparture: formatter.date(from: date)!,
      availableSeatCount: seatCount,
      ticketPrice: price
    )

    busTrips["avalible", default: []].insert(newTrip)

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    let data = try encoder.encode(busTrips)
    try data.write(to: fileURL)

    print(String(data: data, encoding: .utf8)!)
  }
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