//
//  LiveLogInspectorViewController.swift
//  CleanroomLogger
//
//  Created by Evan Maloney on 2/18/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

#if os(iOS) || os(tvOS)
    
    import Foundation
    import UIKit
    
    /**
     The `LiveLogInspectorViewController` provides a live view of the `LogEntry`
     messages recorded by a `BufferedLogEntryMessageRecorder`.
     
     Typically, you would not construct a `LiveLogInspectorViewController`
     directly; instead, you would add a `LiveLogInspectorConfiguration` to your
     CleanroomLogger configuration and use its `inspectorViewController`
     property to acquire a `LiveLogInspectorViewController` instance.
     */
    open class LiveLogInspectorViewController: UINavigationController
    {
        let dataSource: LiveLogInspectorDataSource
        
        private var orderButton: UIBarButtonItem = {
            return UIBarButtonItem(
                image: Noun756735.image(),
                style: .plain,
                target: self,
                action: #selector(LiveLogInspectorViewController.onOrderButtonPressed))
        }()
        
        private var flexibleSpace: UIBarButtonItem = {
            return UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        }()
        
        private var severityButton: UIBarButtonItem = {
            return UIBarButtonItem(
                title: LogSeverity.verbose.description,
                style: .plain,
                target: self,
                action: #selector(LiveLogInspectorViewController.onSeverityButtonPressed))
        }()
        
        private var doneButton: UIBarButtonItem = {
            return UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(LiveLogInspectorViewController.onDoneButtonPressed))
        }()
        
        func onDoneButtonPressed() {
            dismiss(animated: true, completion: nil)
        }
        
        func onOrderButtonPressed() {
            switch dataSource.order {
            case .asc:
                orderButton.image = Noun756734.image()
                dataSource.order = .desc
            case .desc:
                orderButton.image = Noun756735.image()
                dataSource.order = .asc
            }
        }
        
        func onSeverityButtonPressed() {
            let sheet = UIAlertController(
                title: "Minimum Severity Level",
                message: nil,
                preferredStyle: .actionSheet)
            sheet.addAction(UIAlertAction(
                title: LogSeverity.verbose.description,
                style: .default) { [weak self] _ in
                    self?.dataSource.minimumSeverity = LogSeverity.verbose
                    self?.severityButton.title = LogSeverity.verbose.description
            })
            sheet.addAction(UIAlertAction(
                title: LogSeverity.debug.description,
                style: .default) { [weak self] _ in
                    self?.dataSource.minimumSeverity = LogSeverity.debug
                    self?.severityButton.title = LogSeverity.debug.description
            })
            sheet.addAction(UIAlertAction(
                title: LogSeverity.info.description,
                style: .default) { [weak self] _ in
                    self?.dataSource.minimumSeverity = LogSeverity.info
                    self?.severityButton.title = LogSeverity.info.description
            })
            sheet.addAction(UIAlertAction(
                title: LogSeverity.warning.description,
                style: .default) { [weak self] _ in
                    self?.dataSource.minimumSeverity = LogSeverity.warning
                    self?.severityButton.title = LogSeverity.warning.description
            })
            sheet.addAction(UIAlertAction(
                title: LogSeverity.error.description,
                style: .default) { [weak self] _ in
                    self?.dataSource.minimumSeverity = LogSeverity.error
                    self?.severityButton.title = LogSeverity.error.description
            })
            sheet.addAction(UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil))
            present(sheet, animated: true, completion: nil)
        }
        
        /**
         Constructs a new `LiveLogInspectorViewController` that will show a live
         display of each `LogEntry` recorded by the passed-in
         `BufferedLogEntryMessageRecorder`.
         
         - parameter recorder: The `BufferedLogEntryMessageRecorder` whose
         content should be displayed by the view controller.
         */
        public init(recorder: BufferedLogEntryMessageRecorder) {
            
            dataSource = LiveLogInspectorDataSource(recorder: recorder)
            super.init(nibName: nil, bundle: nil)
            isToolbarHidden = false
            toolbar.isOpaque = true
            toolbar.isTranslucent = false
            let vc = UITableViewController(style: .grouped)
            pushViewController(vc, animated: false)
            vc.setToolbarItems([severityButton, flexibleSpace, orderButton], animated: false)
            vc.navigationItem.rightBarButtonItem = doneButton
            vc.title = "Console"
            vc.tableView.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: -38, right: 0)
            dataSource.tableView = vc.tableView
        }
        
        /**
         Not supported. Results in a fatal error when called.
         
         - parameter coder: Ignored.
         */
        public required init?(coder: NSCoder) { fatalError() }
        
    }
    
    private class Noun756734: NSObject {
        
        class func draw(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 16, height: 14), resizing: ResizingBehavior = .aspectFit) {
            /// General Declarations
            let context = UIGraphicsGetCurrentContext()!
            
            /// Resize to Target Frame
            context.saveGState()
            let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 16, height: 14), target: targetFrame)
            context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
            context.scaleBy(x: resizedFrame.width / 16, y: resizedFrame.height / 14)
            context.translateBy(x: -4, y: -5)
            
            /// noun_756734_cc
            do {
                context.saveGState()
                context.translateBy(x: 4, y: 5)
                
                /// Group
                do {
                    context.saveGState()
                    
                    /// Group
                    do {
                        context.saveGState()
                        
                        /// Shape
                        let shape = UIBezierPath()
                        shape.move(to: CGPoint(x: 3.5, y: 14))
                        shape.addLine(to: CGPoint(x: 0, y: 10))
                        shape.addLine(to: CGPoint(x: 7, y: 10))
                        shape.addLine(to: CGPoint(x: 3.5, y: 14))
                        shape.close()
                        shape.move(to: CGPoint(x: 7, y: 3))
                        shape.addLine(to: CGPoint(x: 16, y: 3))
                        shape.addLine(to: CGPoint(x: 16, y: 4))
                        shape.addLine(to: CGPoint(x: 7, y: 4))
                        shape.addLine(to: CGPoint(x: 7, y: 3))
                        shape.close()
                        shape.move(to: CGPoint(x: 10, y: 6))
                        shape.addLine(to: CGPoint(x: 16, y: 6))
                        shape.addLine(to: CGPoint(x: 16, y: 7))
                        shape.addLine(to: CGPoint(x: 10, y: 7))
                        shape.addLine(to: CGPoint(x: 10, y: 6))
                        shape.close()
                        shape.move(to: CGPoint(x: 7, y: 0))
                        shape.addLine(to: CGPoint(x: 16, y: 0))
                        shape.addLine(to: CGPoint(x: 16, y: 1))
                        shape.addLine(to: CGPoint(x: 7, y: 1))
                        shape.addLine(to: CGPoint(x: 7, y: 0))
                        shape.close()
                        shape.move(to: CGPoint(x: 8, y: 9))
                        shape.addLine(to: CGPoint(x: 16, y: 9))
                        shape.addLine(to: CGPoint(x: 16, y: 10))
                        shape.addLine(to: CGPoint(x: 8, y: 10))
                        shape.addLine(to: CGPoint(x: 8, y: 9))
                        shape.close()
                        shape.move(to: CGPoint(x: 8, y: 12))
                        shape.addLine(to: CGPoint(x: 16, y: 12))
                        shape.addLine(to: CGPoint(x: 16, y: 13))
                        shape.addLine(to: CGPoint(x: 8, y: 13))
                        shape.addLine(to: CGPoint(x: 8, y: 12))
                        shape.close()
                        shape.move(to: CGPoint(x: 3, y: 0))
                        shape.addLine(to: CGPoint(x: 4, y: 0))
                        shape.addLine(to: CGPoint(x: 4, y: 10))
                        shape.addLine(to: CGPoint(x: 3, y: 10))
                        shape.addLine(to: CGPoint(x: 3, y: 0))
                        shape.close()
                        shape.move(to: CGPoint(x: 3, y: 0))
                        context.saveGState()
                        UIColor.black.setFill()
                        shape.fill()
                        context.restoreGState()
                        
                        context.restoreGState()
                    }
                    
                    context.restoreGState()
                }
                
                context.restoreGState()
            }
            
            context.restoreGState()
        }
        
        
        //MARK: - Canvas Images
        
        /// Noun756734
        
        class func image() -> UIImage {
            struct LocalCache {
                static var image: UIImage!
            }
            if LocalCache.image != nil {
                return LocalCache.image
            }
            var image: UIImage
            
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 16, height: 14), false, 0)
            Noun756734.draw()
            image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            LocalCache.image = image
            return image
        }
        
        
        //MARK: - Resizing Behavior
        
        enum ResizingBehavior {
            case aspectFit /// The content is proportionally resized to fit into the target rectangle.
            case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
            case stretch /// The content is stretched to match the entire target rectangle.
            case center /// The content is centered in the target rectangle, but it is NOT resized.
            
            func apply(rect: CGRect, target: CGRect) -> CGRect {
                if rect == target || target == CGRect.zero {
                    return rect
                }
                
                var scales = CGSize.zero
                scales.width = abs(target.width / rect.width)
                scales.height = abs(target.height / rect.height)
                
                switch self {
                case .aspectFit:
                    scales.width = min(scales.width, scales.height)
                    scales.height = scales.width
                case .aspectFill:
                    scales.width = max(scales.width, scales.height)
                    scales.height = scales.width
                case .stretch:
                    break
                case .center:
                    scales.width = 1
                    scales.height = 1
                }
                
                var result = rect.standardized
                result.size.width *= scales.width
                result.size.height *= scales.height
                result.origin.x = target.minX + (target.width - result.width) / 2
                result.origin.y = target.minY + (target.height - result.height) / 2
                return result
            }
        }
        
        
    }

    private class Noun756735: NSObject {
        
        
        //MARK: - Canvas Drawings
        
        /// Noun756735
        
        class func draw(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 16, height: 14), resizing: ResizingBehavior = .aspectFit) {
            /// General Declarations
            let context = UIGraphicsGetCurrentContext()!
            
            /// Resize to Target Frame
            context.saveGState()
            let resizedFrame = resizing.apply(rect: CGRect(x: 0, y: 0, width: 16, height: 14), target: targetFrame)
            context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
            context.scaleBy(x: resizedFrame.width / 16, y: resizedFrame.height / 14)
            context.translateBy(x: -4, y: -5)
            
            /// noun_756735_cc
            do {
                context.saveGState()
                context.translateBy(x: 4, y: 5)
                
                /// Group
                do {
                    context.saveGState()
                    
                    /// Group
                    do {
                        context.saveGState()
                        
                        /// Shape
                        let shape = UIBezierPath()
                        shape.move(to: CGPoint(x: 3, y: 10))
                        shape.addLine(to: CGPoint(x: 0, y: 10))
                        shape.addLine(to: CGPoint(x: 3.5, y: 14))
                        shape.addLine(to: CGPoint(x: 7, y: 10))
                        shape.addLine(to: CGPoint(x: 4, y: 10))
                        shape.addLine(to: CGPoint(x: 4, y: 0))
                        shape.addLine(to: CGPoint(x: 3, y: 0))
                        shape.addLine(to: CGPoint(x: 3, y: 10))
                        shape.close()
                        shape.move(to: CGPoint(x: 7, y: 6))
                        shape.addLine(to: CGPoint(x: 16, y: 6))
                        shape.addLine(to: CGPoint(x: 16, y: 7))
                        shape.addLine(to: CGPoint(x: 7, y: 7))
                        shape.addLine(to: CGPoint(x: 7, y: 6))
                        shape.close()
                        shape.move(to: CGPoint(x: 10, y: 9))
                        shape.addLine(to: CGPoint(x: 16, y: 9))
                        shape.addLine(to: CGPoint(x: 16, y: 10))
                        shape.addLine(to: CGPoint(x: 10, y: 10))
                        shape.addLine(to: CGPoint(x: 10, y: 9))
                        shape.close()
                        shape.move(to: CGPoint(x: 7, y: 3))
                        shape.addLine(to: CGPoint(x: 16, y: 3))
                        shape.addLine(to: CGPoint(x: 16, y: 4))
                        shape.addLine(to: CGPoint(x: 7, y: 4))
                        shape.addLine(to: CGPoint(x: 7, y: 3))
                        shape.close()
                        shape.move(to: CGPoint(x: 7, y: 0))
                        shape.addLine(to: CGPoint(x: 16, y: 0))
                        shape.addLine(to: CGPoint(x: 16, y: 1))
                        shape.addLine(to: CGPoint(x: 7, y: 1))
                        shape.addLine(to: CGPoint(x: 7, y: 0))
                        shape.close()
                        shape.move(to: CGPoint(x: 8, y: 12))
                        shape.addLine(to: CGPoint(x: 16, y: 12))
                        shape.addLine(to: CGPoint(x: 16, y: 13))
                        shape.addLine(to: CGPoint(x: 8, y: 13))
                        shape.addLine(to: CGPoint(x: 8, y: 12))
                        shape.close()
                        shape.move(to: CGPoint(x: 8, y: 12))
                        context.saveGState()
                        context.translateBy(x: 8, y: 7)
                        context.scaleBy(x: -1, y: 1)
                        context.rotate(by: CGFloat.pi)
                        context.translateBy(x: -8, y: -7)
                        UIColor.black.setFill()
                        shape.fill()
                        context.restoreGState()
                        
                        context.restoreGState()
                    }
                    
                    context.restoreGState()
                }
                
                context.restoreGState()
            }
            
            context.restoreGState()
        }
        
        
        //MARK: - Canvas Images
        
        /// Noun756735
        
        class func image() -> UIImage {
            struct LocalCache {
                static var image: UIImage!
            }
            if LocalCache.image != nil {
                return LocalCache.image
            }
            var image: UIImage
            
            UIGraphicsBeginImageContextWithOptions(CGSize(width: 16, height: 14), false, 0)
            Noun756735.draw()
            image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            LocalCache.image = image
            return image
        }
        
        
        //MARK: - Resizing Behavior
        
        enum ResizingBehavior {
            case aspectFit /// The content is proportionally resized to fit into the target rectangle.
            case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
            case stretch /// The content is stretched to match the entire target rectangle.
            case center /// The content is centered in the target rectangle, but it is NOT resized.
            
            func apply(rect: CGRect, target: CGRect) -> CGRect {
                if rect == target || target == CGRect.zero {
                    return rect
                }
                
                var scales = CGSize.zero
                scales.width = abs(target.width / rect.width)
                scales.height = abs(target.height / rect.height)
                
                switch self {
                case .aspectFit:
                    scales.width = min(scales.width, scales.height)
                    scales.height = scales.width
                case .aspectFill:
                    scales.width = max(scales.width, scales.height)
                    scales.height = scales.width
                case .stretch:
                    break
                case .center:
                    scales.width = 1
                    scales.height = 1
                }
                
                var result = rect.standardized
                result.size.width *= scales.width
                result.size.height *= scales.height
                result.origin.x = target.minX + (target.width - result.width) / 2
                result.origin.y = target.minY + (target.height - result.height) / 2
                return result
            }
        }
        
        
    }

    
#endif
