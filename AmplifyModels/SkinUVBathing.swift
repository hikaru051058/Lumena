// swiftlint:disable all
import Amplify
import Foundation

public enum SkinUvBathing: String, EnumPersistable {
  case moreThan_7Hours = "MORE_THAN_7_HOURS"
  case fiveTo_6Hours = "FIVE_TO_6_HOURS"
  case twoTo_4Hours = "TWO_TO_4_HOURS"
  case oneTo_2Hours = "ONE_TO_2_HOURS"
  case lessThan_1Hour = "LESS_THAN_1_HOUR"
}