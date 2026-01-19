import Foundation

struct Spark: Codable {
    let id: Int
    let name: String
    let description: String
    let type: SparkType
}

enum SparkType: String, Codable {
    case stat = "stat"
    case aptitude = "aptitude"
    case skill = "skill"
    case uniqueSkill = "unique_skill"
}

struct SparkResponse: Codable {
    let sparks: [Spark]
}
