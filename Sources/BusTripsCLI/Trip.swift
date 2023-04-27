//
// BusTrip CLI
//

import Foundation

/// A type that represents a trip.
struct Trip {
  /// The route of the trip.
  var route: Route
  /// The date of departure of the bus trip.
  var dateOfDeparture: Date
  /// The number of seats available for booking.
  var availableSeatCount: Int
  /// The ticket price per seat.
  var ticketPrice: Double

  /// Date format in string representation.
  static let dateFormat = "yyyy-MM-dd HH:mm"
}
