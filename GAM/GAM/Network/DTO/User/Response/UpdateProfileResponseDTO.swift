//
//  UpdateProfileResponseDTO.swift
//  GAM
//
//  Created by Juhyeon Byun on 1/13/24.
//

import Foundation

struct UpdateProfileResponseDTO: Decodable {
    let userInfo: String
    let userDetail: String
    let email: String
    let tags: [Int]
    let userName: String
}

extension UpdateProfileResponseDTO {
    func toUserProfileEntity() -> UserProfileEntity {
        return UserProfileEntity(userID: 0,
                                 name: userName,
                                 isScrap: false,
                                 info: userInfo,
                                 infoDetail: userDetail,
                                 tags: tags,
                                 email: email)
    }
}
