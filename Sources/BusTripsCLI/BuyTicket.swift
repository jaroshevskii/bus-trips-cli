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
      var busTrips = readBusTrips(from: fileURL),
      var availableTrips = busTrips["available"],
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

    print("Trip number: ", terminator: "")

    guard let enteredStirng = readLine() else {
      print("Error: Unable to read the entered string.")
      return      
    }
    guard var tripNumber = Int(enteredStirng) else {
      print("Error: The entered string doesn't look like a number.")
      return
    }
    let tripsRange = 1...availableTrips.count
    guard tripsRange.contains(tripNumber) else {
      print("""
      Error: There is no route with a sequential number in the trip list.
      Tip:   The trip number must be in the range [\(tripsRange)].
      """)
      return
    }
    tripNumber = tripNumber - 1
    guard availableTrips[tripNumber].availableSeatCount != 0 else {
      print("\nSorry, but there are no more seats left in the trip.")
      return
    }

    print("Seat count: ", terminator: "")

    guard let enteredStirng = readLine() else {
      print("Error: Unable to read the entered string.")
      return
    }
    guard let seatCount = Int(enteredStirng) else {
      print("Error: The entered string doesn't look like a number.")
      return
    }
    let seatCountRange = 1...availableTrips[tripNumber].availableSeatCount
    guard seatCountRange.contains(seatCount) else {
      print("""
      Error: There is no route with a sequential number in the trip list.
      Tip:   The seat count must be in the range [\(seatCountRange)].
      """)
      return
    }

    availableTrips[tripNumber].availableSeatCount = availableTrips[tripNumber].availableSeatCount - seatCount
    availableTrips[tripNumber].tickets.append(seatCount)
    busTrips["available"] = availableTrips

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    let data = try encoder.encode(busTrips)
    try data.write(to: fileURL)

    print("\nThe result is saved in a '\(fileURL.path)' file.")
  }

  func readBusTrips(from fileURL: URL) -> [String: [Trip]]? {
    guard let data = try? Data(contentsOf: fileURL) else {
      return nil
    }
    
    let decoder = JSONDecoder()
    return try? decoder.decode([String: [Trip]].self, from: data)
  }
}