//
//  CheckPermissionResponseDTO.swift
//  GAM
//
//  Created by Jungbin on 6/1/24.
//

import Foundation

struct CheckPermissionResponseDTO: Decodable {
    let userStatus: String
    let magazineCount: Int
}
