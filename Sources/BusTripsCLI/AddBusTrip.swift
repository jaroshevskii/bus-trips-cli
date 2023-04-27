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

  @Option(help: "Route of the bus trip.")
  var route: String = "dfgdf"

  @Option(help: "Date of departure of the bus trip. (format: \(Trip.formatOfDate))")
  var dateOfDeparture: String = ""

  func validate() throws {
  }

  func run() {
    var xx = 9
    xx.trailingZeroBitCount
    
  }
}