//
//  BlockUserRequestDTO.swift
//  GAM
//
//  Created by Juhyeon Byun on 5/9/24.
//

struct BlockUserRequestDTO: Encodable {
    let targetUserId: Int
    let currentBlockStatus: Bool
}
