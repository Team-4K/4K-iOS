//
//  GamMoyaProvider.swift
//  GAM
//
//  Created by Jungbin on 2023/08/23.
//

import Foundation
import Moya

final class GamMoyaProvider<TargetRouter: TargetType>: MoyaProvider<TargetRouter> {
    convenience init(isLoggingOn: Bool = false) {
        self.init(plugins: [NetworkLoggerPlugin()])
        
        let session = Session(interceptor: AuthInterceptor.shared)
        let plugins: [PluginType] = isLoggingOn ? [NetworkLoggerPlugin()] : []
        self.init(session: session, plugins: plugins)
    }
}
