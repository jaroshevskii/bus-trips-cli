//
// BusTrips CLI
//

/// A structure that represents a route.
///
/// `Route` contains the point of departure and arrival.
struct Route {
  /// The name of the route departure point.
  let departure: String

  /// The name of the arrival point of the route.
  let arrival: String
  
  init(departure: String, arrival: String) throws {
    if departure.isEmpty || arrival.isEmpty {
      throw RouteError.emptyField
    }
    if departure == arrival {
      throw RouteError.sameDepartureAndArrival
    }
    self.departure = departure
    self.arrival = arrival
  }

  init(_ text: String) throws {
    let parts = text.split(separator: " - ")
    guard parts.count == 2 else {
      throw RouteError.invalidFormat
    }
    try self.init(
      departure: parts.first!.trimmingCharacters(in: .whitespaces),
      arrival: parts.last!.trimmingCharacters(in: .whitespaces))
  }
}

enum RouteError: Error {
  case emptyField
  case sameDepartureAndArrival
  case invalidFormat
}
