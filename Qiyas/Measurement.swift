import Foundation
import SwiftData

@Model
final class Measurement {
    @Attribute(.unique) var id: UUID
    var date: Date
    var unit: String          // "cm" أو "in" مثلًا
    var weight: Double?       // يومي
    var chest: Double?
    var hips: Double?
    var waist: Double?
    var leftArm: Double?
    var rightArm: Double?
    var leftThigh: Double?
    var rightThigh: Double?
    var notes: String?

    init(
        id: UUID = UUID(),
        date: Date = .init(),
        unit: String = "cm",
        weight: Double? = nil,
        chest: Double? = nil,
        hips: Double? = nil,
        waist: Double? = nil,
        leftArm: Double? = nil,
        rightArm: Double? = nil,
        leftThigh: Double? = nil,
        rightThigh: Double? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.unit = unit
        self.weight = weight
        self.chest = chest
        self.hips = hips
        self.waist = waist
        self.leftArm = leftArm
        self.rightArm = rightArm
        self.leftThigh = leftThigh
        self.rightThigh = rightThigh
        self.notes = notes
    }
}

