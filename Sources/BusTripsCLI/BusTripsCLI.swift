//
// BusTrips CLI
//

import ArgumentParser

@main
struct BusTripsCLI: ParsableCommand {
  static var configuration = CommandConfiguration(
    commandName: "bustrips",
    abstract: "A command line tool for managing bus trips.",
    version: "X.X.X",
    subcommands: [AddBusTrip.self]
  )

  func run() {
    print("""
      BusTrips \
      CLI
      """)
  }
}