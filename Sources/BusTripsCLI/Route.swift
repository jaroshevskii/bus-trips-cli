//
// BusTrips CLI
//

/// A type represents a route that contains departure and arrival points.
struct Route: Codable, Hashable {
  /// The departure point of the route.
  let departure: String
  
  /// The arrival point of the route.
  let arrival: String

  /// The separator for a string representation of the route.
  static let separator = " - "

  /// A string representation of the route.
  var description: String { departure + Self.separator + arrival }
  
  /// Creates a new route instance with the given departure and arrival points.
  ///
  /// - Parameters:
  ///   - departure: The departure point of the route.
  ///   - arrival: The arrival point of the route.
  ///
  /// - Throws:
  ///   - `RouteError.emptyField` if the departure or arrival is an empty string.
  ///   - `RouteError.sameDepartureAndArrival` if the departure and arrival are the same.
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

  /// Creates a new route from the given string.
  ///
  /// - Parameter description: A string containing departure and arrival points separated by `Route.separator`.
  ///
  /// - Throws:
  ///   - `RouteError.invalidFormat` if the description doesn't contain departure and arrival points separated by `Route.separator`.
  ///   - Errors thrown by `init(departure:arrival:)`.
  init(_ description: String) throws {
    let routeComponents = description.split(separator: Self.separator)
    guard routeComponents.count == 2 else {
      throw RouteError.invalidFormat
    }
    try self.init(
      departure: routeComponents.first!.trimmingCharacters(in: .whitespaces),
      arrival: routeComponents.last!.trimmingCharacters(in: .whitespaces))
  }
}

/// An error that can be thrown when working with `Route`.
enum RouteError: Error {
  case emptyField
  case sameDepartureAndArrival
  case invalidFormat
}
