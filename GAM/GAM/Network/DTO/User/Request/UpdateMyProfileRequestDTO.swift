//
//  UpdateMyProfileRequestDTO.swift
//  GAM
//
//  Created by Juhyeon Byun on 1/13/24.
//

import Foundation

struct UpdateMyProfileRequestDTO: Encodable {
    let userInfo: String
    let userDetail: String
    let email: String
    let tags: [Int]
    let userName: String
    
    init(userInfo: String, userDetail: String, email: String, tags: [Int], userName: String) {
        self.userInfo = userInfo
        self.userDetail = userDetail
        self.email = email
        self.tags = tags
        self.userName = userName
    }
}
