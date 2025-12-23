import Foundation

struct Herb: Identifiable, Codable {
    let id: String
    let name: String
    let scientificName: String
    let category: String
    let properties: String
    let taste: String
    let meridians: [String]
    let functions: [String]
    let indications: [String]
    let dosage: String
    let precautions: [String]
    let imageUrl: String
    let description: String
}
