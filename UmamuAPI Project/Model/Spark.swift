//
//  Spark.swift
//  UmamuAPI Project
//
//  Created by alumne on 19/01/2026.
//

import Foundation

struct Spark{
    let id: UInt
    var name: String
    var rarity: UInt8
    var description: String
    var type: SparkType
}

enum SparkType: String {
    case stat = "STAT"
    case aptitude = "APTITUDE"
    case skill = "SKILL"
    case uniqueSkill = "UNIQUE_SKILL"
}
