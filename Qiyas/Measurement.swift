import Foundation
import SwiftData

@Model
final class Measurement {
    @Attribute(.unique) var id: UUID
    var date: Date
    var unit: String        // "cm" أو "in"
    // القياسات الأساسية
    var waist: Double?      // البطن/الخصر
    var hips: Double?       // الورك
    var chest: Double?      // الصدر
    var weight: Double?     // الوزن (اختياري: بالكيلو)
    // يمين/يسار
    var rightArm: Double?
    var leftArm: Double?
    var rightThigh: Double?
    var leftThigh: Double?
    // ملاحظات
    var notes: String?

    init(
        id: UUID = UUID(),
        date: Date = .now,
        unit: String = "cm",
        waist: Double? = nil,
        hips: Double? = nil,
        chest: Double? = nil,
        weight: Double? = nil,
        rightArm: Double? = nil,
        leftArm: Double? = nil,
        rightThigh: Double? = nil,
        leftThigh: Double? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.unit = unit
        self.waist = waist
        self.hips = hips
        self.chest = chest
        self.weight = weight
        self.rightArm = rightArm
        self.leftArm = leftArm
        self.rightThigh = rightThigh
        self.leftThigh = leftThigh
        self.notes = notes
    }
}

