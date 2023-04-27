//
// BusTrip CLI
//

import Foundation

struct Trip {
  var route: Route
  var dateOfDeparture: Date
}

extension Trip {
  static let formatOfDate = "yyyy-MM-dd HH:mm"
}