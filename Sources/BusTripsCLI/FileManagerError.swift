//
// BusTrips CLI
//

import Foundation

/// An error that can be thrown when working with `FileManager`.
enum FileManagerError: Error {
  case desktopDirectoryPathNotFound
}

extension FileManagerError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .desktopDirectoryPathNotFound:
      return "Can't find the path to the desktop directory."
    }
  }
}