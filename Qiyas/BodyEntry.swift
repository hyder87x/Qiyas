import Foundation
import SwiftData

@Model
public final class BodyEntry {
    public var id: UUID
    public var date: Date
    /// وحدة الأطوال: "cm" أو "in"
    public var unit: String

    // القيم الأساسية (المهمة أولاً)
    public var weight: Double?   // Kg
    public var waist: Double?    // cm/in
    public var hips: Double?     // cm/in
    public var neck: Double?     // cm/in

    // إضافية: أذرع
    public var leftArm: Double?
    public var rightArm: Double?
    public var leftForearm: Double?
    public var rightForearm: Double?

    // إضافية: أرجل
    public var leftThigh: Double?
    public var rightThigh: Double?
    public var leftKnee: Double?
    public var rightKnee: Double?

    // إضافية: صدر وكتف
    public var chest: Double?
    public var shoulder: Double?

    public var notes: String?

    public init(
        id: UUID = UUID(),
        date: Date,
        unit: String,
        weight: Double? = nil,
        waist: Double? = nil,
        hips: Double? = nil,
        neck: Double? = nil,
        leftArm: Double? = nil,
        rightArm: Double? = nil,
        leftForearm: Double? = nil,
        rightForearm: Double? = nil,
        leftThigh: Double? = nil,
        rightThigh: Double? = nil,
        leftKnee: Double? = nil,
        rightKnee: Double? = nil,
        chest: Double? = nil,
        shoulder: Double? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.unit = unit
        self.weight = weight
        self.waist = waist
        self.hips = hips
        self.neck = neck
        self.leftArm = leftArm
        self.rightArm = rightArm
        self.leftForearm = leftForearm
        self.rightForearm = rightForearm
        self.leftThigh = leftThigh
        self.rightThigh = rightThigh
        self.leftKnee = leftKnee
        self.rightKnee = rightKnee
        self.chest = chest
        self.shoulder = shoulder
        self.notes = notes
    }
}
