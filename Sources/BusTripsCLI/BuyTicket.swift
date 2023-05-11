//
// BusTrips CLI
//

import Foundation
import ArgumentParser

struct BuyTicket: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "buy",
    abstract: "Buy a ticket for the specified trip."
  )

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

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = Trip.dateFormat

    print("Available bus trips:")
    for (index, trip) in availableTrips.enumerated() {
      let indent = String(repeating: " ", count: "\(availableTrips.count).".count)
      let formatedIndex = "\(index + 1)." + String(repeating: " ", count: indent.count - "\(index + 1).".count)
      let formatedDate = dateFormatter.string(from: trip.dateOfDeparture)
      let formatedPrice = trip.ticketPrice.isZero ? "free" : "$" + String(format: "%g", trip.ticketPrice)
      
      print("""
      \(formatedIndex) Route:                \(trip.route.description)
      \(indent) Date of departure:    \(formatedDate)
      \(indent) Available seat count: \(trip.availableSeatCount)
      \(indent) Tiket price:          \(formatedPrice)

      """)
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