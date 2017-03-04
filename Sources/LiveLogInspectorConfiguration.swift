//
//  LiveLogInspectorConfiguration.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 2/17/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit

open class LiveLogInspectorConfiguration: BasicLogConfiguration
{
    private let bufferingRecorder: BufferedLogEntryMessageRecorder

    public init(minimumSeverity: LogSeverity = .verbose, filters: [LogFilter] = [], synchronousMode: Bool = false)
    {
        bufferingRecorder = BufferedLogEntryMessageRecorder(formatters: [PayloadLogFormatter()])

        super.init(minimumSeverity: minimumSeverity, filters: filters, recorders: [bufferingRecorder], synchronousMode: synchronousMode)
    }

    public func inspectorViewController() -> LiveLogInspectorViewController {
        return LiveLogInspectorViewController(recorder: bufferingRecorder)
    }
    
    public func inspectorViewDataSource() -> LiveLogInspectorDataSource {
        return LiveLogInspectorDataSource(recorder: bufferingRecorder)
    }
}

#endif

