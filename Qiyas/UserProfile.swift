import SwiftUI
import SwiftData

@Model
public final class UserProfile {
    public var name: String
    public var age: Int?
    public var heightCm: Double?
    public var sex: Sex   // Sex معرّفة في UIShared.swift فقط

    public init(
        name: String = "",
        age: Int? = nil,
        heightCm: Double? = nil,
        sex: Sex = .male
    ) {
        self.name = name
        self.age = age
        self.heightCm = heightCm
        self.sex = sex
    }
}

