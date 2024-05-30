//
//  UserProfileEntity.swift
//  GAM
//
//  Created by Jungbin on 2023/07/27.
//

import Foundation

struct UserProfileEntity {
    var userID: Int
    var name: String
    var isScrap: Bool
    var info: String
    var infoDetail: String
    var tags: [TagEntity]
    var email: String
    
    static func == (lhs: UserProfileEntity, rhs: UserProfileEntity) -> Bool {
        return lhs.userID == rhs.userID
    }
    
    init(userID: Int, name: String, isScrap: Bool, info: String, infoDetail: String, tags: [Int], email: String) {
        self.userID = userID
        self.name = name
        self.isScrap = isScrap
        self.info = info
        self.infoDetail = infoDetail
        self.tags = Tag.shared.mapTags(tags)
        self.email = email
    }
}
