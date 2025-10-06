import Foundation
import SwiftData

@Model
final class Measurement {
    // متى تم الإدخال
    var date: Date

    // وحدة القياس (غالبًا "cm")
    var unit: String

    // وزن (كجم)
    var weight: Double?

    // محيطات
    var waist: Double?
    var hips: Double?
    var chest: Double?
    var neck: Double?          // NEW

    // أذرع
    var leftArm: Double?
    var rightArm: Double?

    // أفخاذ
    var leftThigh: Double?
    var rightThigh: Double?

    // ملاحظات
    var notes: String?

    init(
        date: Date = Date(),
        unit: String = "cm",
        weight: Double? = nil,
        waist: Double? = nil,
        hips: Double? = nil,
        chest: Double? = nil,
        neck: Double? = nil,
        leftArm: Double? = nil,
        rightArm: Double? = nil,
        leftThigh: Double? = nil,
        rightThigh: Double? = nil,
        notes: String? = nil
    ) {
        self.date = date
        self.unit = unit
        self.weight = weight
        self.waist = waist
        self.hips = hips
        self.chest = chest
        self.neck = neck
        self.leftArm = leftArm
        self.rightArm = rightArm
        self.leftThigh = leftThigh
        self.rightThigh = rightThigh
        self.notes = notes
    }
}

