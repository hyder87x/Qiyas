import Foundation
import SwiftData

@Model
final class UserProfile {
    var name: String
    var age: Int?
    var heightCm: Double?          // الطول بالسنتيمتر

    // نخزن الجنس كبوليان (مريح لِـ SwiftData)
    private var isFemaleStorage: Bool

    init(
        name: String = "",
        age: Int? = nil,
        heightCm: Double? = nil,
        sex: Sex = .male            // enum Sex موجود في UIShared.swift
    ) {
        self.name = name
        self.age = age
        self.heightCm = heightCm
        self.isFemaleStorage = (sex == .female)
    }

    // واجهة مريحة لباقي الكود: نتعامل مع Sex بدل Bool
    // مهم: نميزها كخاصية غير محفوظة في SwiftData
    @Transient
    var sex: Sex {
        get { isFemaleStorage ? .female : .male }
        set { isFemaleStorage = (newValue == .female) }
    }
}

