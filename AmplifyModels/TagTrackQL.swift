// swiftlint:disable all
import Amplify
import Foundation

public struct TagTrackQL: Embeddable {
  var trackID: String
  var tagMusicRange: [Double]
}