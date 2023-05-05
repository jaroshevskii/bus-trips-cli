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
    do {
      _ = try Route(route)
    } catch RouteError.emptyField {
      throw ValidationError("The route cannot contain empty points.")
    } catch RouteError.sameDepartureAndArrival {
      throw ValidationError("Departure and arrival points cannot be the same.")
    } catch RouteError.invalidFormat {
      throw ValidationError("The route must contain departure and arrival points separated by '\(Route.separator)'.")
    }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = Trip.dateFormat
    guard let date = dateFormatter.date(from: date) else {
      throw ValidationError("The date should be in the format '\(Trip.dateFormat)'.")
    }
    guard date > .now else {
      throw ValidationError("The departure date must be in the future.")
    }

    guard seatCount >= 1 else {
      throw ValidationError("There must be at least one free seat.")
    }

    guard price >= 0 else {
      throw ValidationError("The ticket price cannot be negative.")
    }
  }

  func run() throws {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = Trip.dateFormat

    let busTrip = Trip(
      route: try! Route(route),
      dateOfDeparture: dateFormatter.date(from: date)!,
      availableSeatCount: seatCount,
      ticketPrice: price
    )

    // print(busTrip)


    let fileManager = FileManager.default
    let desktopURL = fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first!
    let filePath = desktopURL.appendingPathComponent("BusTrip.json")
    let fileExists = fileManager.fileExists(atPath: filePath.path)
    var busTrips: [Trip] = []

    if fileExists {
      // File exists, so read the contents and decode the array
      let data = try Data(contentsOf: filePath)
      let decoder = JSONDecoder()
      busTrips = try decoder.decode([Trip].self, from: data)
    }

    busTrips.append(busTrip)

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    // let encodedBusTrip = try encoder.encode([busTrip])
    // print(String(data: encodedBusTrip, encoding: .utf8)!)
    // print(encodedBusTrip)

    let jsonData = try encoder.encode(busTrips)
    let desktopPath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
    let fileURL = desktopPath.appendingPathComponent("BusTrip.json")
    try jsonData.write(to: fileURL)
  }
}