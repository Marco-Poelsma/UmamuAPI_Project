import Foundation

struct Umamusume: Codable, Identifiable {
    let id: Int
    var name: String
    var sparks: [UmamusumeSpark]
    var inspirationID1: Int
    var inspirationID2: Int
    var isFavourite: Bool = false

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case sparks
        case inspirationID1 = "inspiration_id_1"
        case inspirationID2 = "inspiration_id_2"
    }
    
    struct UmamusumeResponse: Codable {
        let properties: [Umamusume]
    }


    
    struct UmamusumeSpark: Codable, Identifiable {
        let spark: Int
        let rarity: Int
        
        var id: Int { spark }
    }

}
