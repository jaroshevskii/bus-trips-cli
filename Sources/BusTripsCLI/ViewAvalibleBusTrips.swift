//
// BusTrips CLI
//

import Foundation
import ArgumentParser

struct ViewAvailableBusTrips: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "view",
    abstract: "View the list of available trips."
  )

  @Option(help: "Filter by departure location.")
  var departure: String?

  @Option(help: "Filter by arrival location.")
  var arrival: String?

  @Option(help: "Filter by date.")
  var date: String?

  @Flag var bought = false

  func validate() throws {
    if let departure = departure, departure.isEmpty {
      throw ValidationError("The departure point cannot be empty.")
    }
    if let arrival = arrival, arrival.isEmpty {
      throw ValidationError("The arrival point cannot be empty.")
    }

    if let date = date {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = Trip.dateFormat

      guard let _ = dateFormatter.date(from: date) else {
        throw ValidationError("The date should be in the format '\(Trip.dateFormat)'.")
      }
    }
  }

  func run() throws {
    let fileManager = FileManager.default
    guard let desktopURL = fileManager.urls(for: .desktopDirectory, in: .userDomainMask).first else {
      throw FileManagerError.desktopDirectoryPathNotFound
    }

    let fileURL = desktopURL.appendingPathComponent("BusTrips.json")
    guard fileManager.fileExists(atPath: fileURL.path),
      let busTrips = readBusTrips(from: fileURL),
      let availableTrips = busTrips["available"],
      !availableTrips.isEmpty else {
      print("""
      Note: There are no trips available.
      Tip:  You can add a new trip by running the 'bustrips add' command.
      """)
      return
    }

    var filteredAvailableTrips = availableTrips

    if let departure = departure {
      filteredAvailableTrips = filteredAvailableTrips.filter { $0.route.departure == departure }
    }
    if let arrival = arrival {
      filteredAvailableTrips = filteredAvailableTrips.filter { $0.route.arrival == arrival }
    }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = Trip.dateFormat

    if let date = date {
      filteredAvailableTrips = filteredAvailableTrips.filter {
        $0.dateOfDeparture == dateFormatter.date(from: date)
      }
    }

    if bought {
      print("Bought bustrips:")
    } else {
      print("Available bus trips:")
    }
    for trip in filteredAvailableTrips {
      if trip.tickets.isEmpty { continue }
      let formatedDate = dateFormatter.string(from: trip.dateOfDeparture)
      let formatedPrice = trip.ticketPrice.isZero ? "free" : "$" + String(format: "%g", trip.ticketPrice)
      if bought {
        print("  \(trip.route.description), \(formatedDate)")
        for seatCount in trip.tickets {
          let price = Double(seatCount) * trip.ticketPrice
          let formatedPrice = price.isZero ? "free" : "$" + String(format: "%g", price)
          print("    \(seatCount) - \(formatedPrice)")
        }
        print()
      } else {
        print("""
          Route:                \(trip.route.description)
          Date of departure:    \(formatedDate)
          Available seat count: \(trip.availableSeatCount)
          Tiket price:          \(formatedPrice)

        """)
      }
    }
  }

  func readBusTrips(from fileURL: URL) -> [String: Set<Trip>]? {
    guard let data = try? Data(contentsOf: fileURL) else {
      return nil
    }
    
    let decoder = JSONDecoder()
    return try? decoder.decode([String: Set<Trip>].self, from: data)
  }
}