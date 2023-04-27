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

  // @Option(help: "The number of seats available for booking.")
  // var seatCount: Int

  // @Option(help: "The ticket price is for one seat.")
  // var price: Double

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
  }

  func run() {
    print(route)
  }
}