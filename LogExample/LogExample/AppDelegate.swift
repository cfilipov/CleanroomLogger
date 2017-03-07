//
//  AppDelegate.swift
//  LogExample
//
//  Created by CF on 3/2/17.
//  Copyright © 2017 CF. All rights reserved.
//

import UIKit
import CleanroomLogger

public let liveLogInspectorConfiguration = LiveLogInspectorConfiguration(
    minimumSeverity: .verbose,
    filters: [],
    synchronousMode: false)

let sampleLogs: [() -> ()] = [
    { _ in Log.verbose?.message("Very short message") },
    { _ in Log.verbose?.message("Another short message") },
    { _ in Log.verbose?.message("One short message") },
    { _ in Log.verbose?.message("Common message") },
    { _ in Log.verbose?.message("Lorem ipsum dolor sit amet.") },
    { _ in Log.verbose?.message("Logging reallyLongSelectorNameThatShouldCauseTroubleWrapAroundAndBlahBlahBlahBlahFooBarBazIncBearBottleBatteryBellyBrewDone.") },
    { _ in Log.debug?.message("Started coffee") },
    { _ in Log.info?.message("Short message") },
    { _ in Log.info?.message("Long message, Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin nec commodo elit. Curabitur imperdiet, enim nec ultricies egestas, eros lacus varius dui, ut rhoncus mi lorem eu ligula. Quisque fringilla ullamcorper mauris eu posuere. Aenean non purus leo. Maecenas aliquet nulla ut purus pharetra finibus. Fusce convallis enim sit amet vulputate rhoncus. Maecenas interdum iaculis mi luctus luctus.") },
    { _ in Log.warning?.message("Something might go wrong... Lorem ipsum dolor sit amet, consectetur adipiscing elit.") },
    { _ in Log.error?.message("Failed to do something.") },
]

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
        sampleLogs[Int(arc4random_uniform(UInt32(sampleLogs.count)))]()
    }
    
    override init() {
        super.init()
        Log.enable(configuration: [
//            XcodeLogConfiguration(
//                minimumSeverity: .verbose,
//                debugMode: true,
//                verboseDebugMode: true,
//                stdStreamsMode: .useExclusively,
//                mimicOSLogOutput: false,
//                showCallSite: true,
//                filters: []),
            liveLogInspectorConfiguration
            ])
        Log.info?.message("👉 This is the very first log message of the stream. There will be many other messages following it, but this is the first message.")
    }

}
