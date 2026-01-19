import Foundation

struct UmamusumeResponse: Codable {
    let properties: [Umamusume]

    private enum CodingKeys: String, CodingKey {
        case properties = "properties:"
    }
}
