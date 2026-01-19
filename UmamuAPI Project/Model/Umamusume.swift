import Foundation

struct Umamusume: Codable {
    let id: Int
    var name: String
    var sparks: [Int]
    var inspirationID1: Int
    var inspirationID2: Int

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case sparks
        case inspirationID1 = "inspiration_id_1"
        case inspirationID2 = "inspiration_id_2"
    }
}
