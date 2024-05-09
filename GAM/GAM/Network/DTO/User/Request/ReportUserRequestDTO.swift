//
//  ReportUserRequestDTO.swift
//  GAM
//
//  Created by Juhyeon Byun on 5/9/24.
//

struct ReportUserRequestDTO: Encodable {
    let targetUserId: Int
    let content: String
    let workId: Int
}
