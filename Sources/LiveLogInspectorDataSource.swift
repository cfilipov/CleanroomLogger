//
//  LiveLogInspectorDataSource.swift
//  CleanroomLogger
//
//  Created by CF on 3/3/17.
//  Copyright © 2017 Gilt Groupe. All rights reserved.
//

#if os(iOS) || os(tvOS)
    
    import Foundation
    import UIKit
    
    public class LiveLogInspectorDataSource: NSObject {
        
        typealias BufferItem = (LogEntry, String)
        
        public enum SortOrder {
            case asc
            case desc
        }
        
        private enum ScrollToTarget {
            case top
            case bottom
            case auto
        }
        
        fileprivate struct Buffer {
            
            let recorder: BufferedLogEntryMessageRecorder
            var order = SortOrder.asc
            var minimumSeverity = LogSeverity.verbose
            
            private var filteredBuffer: [BufferItem] {
                var buffer = recorder.buffer
                if minimumSeverity != .verbose {
                    buffer = buffer.filter{ $0.0.severity >= self.minimumSeverity }
                }
                return buffer
            }
            
            var count: Int {
                return filteredBuffer.count
            }
            
            func translate(index: Int) -> Int {
                switch (recorder.reverseChronological, order) {
                case (true, .asc), (false, .desc): return filteredBuffer.count - index - 1
                default: return index
                }
            }
            
            subscript(index: Int) -> BufferItem {
                get {
                    return filteredBuffer[translate(index: index)]
                }
            }
        }
        
        fileprivate var rowHeightCache: [String:CGFloat] = [:]
        fileprivate var isFollowing = true
        private var recordItemCallbackHandle: CallbackHandle?
        private var clearBufferCallbackHandle: CallbackHandle?
        private var topIndexPath = IndexPath(row: 0, section: 0)
        
        private var bottomIndexPath: IndexPath {
            return IndexPath(row: buffer.count - 1, section: 0)
        }
        
        private var newestIndexPath: IndexPath {
            return IndexPath(row: buffer.order == .asc ? buffer.count-1 : 0, section: 0)
        }
        
        private var oldestIndexPath: IndexPath {
            return IndexPath(row: buffer.order == .asc ? 0 : buffer.count-1, section: 0)
        }
        
        fileprivate var buffer: Buffer
        
        public weak var tableView: UITableView? = nil {
            didSet {
                guard let tableView = tableView else { fatalError() }
                LogEntryCell.register(tableView)
                tableView.delegate = self
                tableView.dataSource = self
                tableView.rowHeight = UITableViewAutomaticDimension
                tableView.estimatedRowHeight = 40
                tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                tableView.reloadData()
                
                clearBufferCallbackHandle = buffer.recorder.addCallback(didClearBuffer: { _ in
                    DispatchQueue.main.async {
                        self.tableView?.reloadData()
                    }
                })
                
                recordItemCallbackHandle = buffer.recorder.addCallback(didRecordBufferItem: { _, item, didTruncate in
                    
                    guard item.0.severity >= self.minimumSeverity
                        else { return }
                    
                    DispatchQueue.main.sync { [unowned self] in
                        tableView.beginUpdates()
                        
                        if didTruncate {
                            precondition(self.buffer.recorder.bufferLimit > 0)
                            tableView.deleteRows(at: [self.oldestIndexPath], with: .automatic)
                        }
                        
                        tableView.insertRows(at: [self.newestIndexPath], with: .top)
                        tableView.endUpdates()
                        if self.shouldAutoScroll { self.scroll(to: .auto) }
                    }
                })
            }
        }
        
        public var order: SortOrder {
            get {
                return buffer.order
            }
            set {
                buffer.order = newValue
                tableView?.reloadData()
                scroll(to: .auto)
            }
        }
        
        public var minimumSeverity: LogSeverity {
            get {
                return buffer.minimumSeverity
            }
            set {
                buffer.minimumSeverity = newValue
                tableView?.reloadData()
            }
        }
        
        init(recorder: BufferedLogEntryMessageRecorder) {
            self.buffer = Buffer(recorder: recorder, order: .asc, minimumSeverity: .verbose)
        }
        
        private func scroll(to position: ScrollToTarget) {
            switch position {
            case .top: tableView?.scrollToRow(at: topIndexPath, at: .middle, animated: true)
            case .bottom: tableView?.scrollToRow(at: bottomIndexPath, at: .middle, animated: true)
            case .auto:
                switch order {
                case .asc: scroll(to: .bottom)
                case .desc: scroll(to: .top)
                }
            }
        }
        
        private var shouldAutoScroll: Bool {
            return order == .asc && isFollowing
        }
        
    }
    
    extension LiveLogInspectorDataSource: UITableViewDataSource, UITableViewDelegate {
        
        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
            -> Int {
                
                guard section == 0
                    else { return 0 }
                return buffer.count
        }
        
        public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
            -> UITableViewCell {
                
                precondition(indexPath.section == 0)
                let cell = LogEntryCell.dequeue(tableView, for: indexPath)
                let (logEntry, message) = buffer[indexPath.row]
                cell.messageLabel.text = message
                cell.messageLabel.textColor = logEntry.severity.textColor
                cell.contentView.backgroundColor = logEntry.severity.backgroundColor
                cell.selectionStyle = .none
                return cell
        }
        
        public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            
            let (_, message) = buffer[indexPath.row]
            rowHeightCache[message] = cell.frame.size.height
        }
        
        public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
            
            precondition(indexPath.section == 0)
            let (_, message) = buffer[indexPath.row]
            guard let height = rowHeightCache[message]
                else { return UITableViewAutomaticDimension }
            return height
        }
        
        public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            isFollowing = false
        }
        
        public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            guard !isFollowing else { return }
            
            // see if we should automatically enable follow mode
            let bottomPoint = scrollView.contentSize.height - scrollView.bounds.size.height
            
            if (scrollView.contentOffset.y + 10) > bottomPoint {
                isFollowing = true
            }
        }
        
        public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            guard !isFollowing else { return }
            
            // see if we should automatically enable follow mode
            let bottomPoint = scrollView.contentSize.height - scrollView.bounds.size.height
            
            if (scrollView.contentOffset.y + 10) > bottomPoint {
                isFollowing = true
            }
        }
    }
    
    private extension LogSeverity {
        
        var backgroundColor: UIColor {
            switch self {
            case .verbose: return .white
            case .debug: return .white
            case .info: return .white
            case .warning: return #colorLiteral(red: 1, green: 0.9850030541, blue: 0.892736733, alpha: 1)
            case .error: return #colorLiteral(red: 0.9713280797, green: 0.9035632014, blue: 0.9046700597, alpha: 1)
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .verbose: return #colorLiteral(red: 0.8376943668, green: 0.8376943668, blue: 0.8376943668, alpha: 1)
            case .debug: return .darkGray
            case .info: return #colorLiteral(red: 0.0576139912, green: 0, blue: 1, alpha: 1)
            case .warning: return #colorLiteral(red: 0.3802621961, green: 0.2261952758, blue: 0, alpha: 1)
            case .error: return #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
            }
        }
    }
    
    class LogEntryCell: UITableViewCell {
        
        static let reuseIdentifier = "LogEntryCell"
        static let defaultFont = UIFont(name: "Menlo-Regular", size: 12)!
        static var padding = CGFloat(6)
        
        static func register(_ tableView: UITableView) {
            tableView.register(self, forCellReuseIdentifier: reuseIdentifier)
        }
        
        static func dequeue(_ tableView: UITableView, for indexPath: IndexPath) -> LogEntryCell {
            return tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LogEntryCell
        }
        
        private static let labelProto: UILabel = {
            let labelProto = UILabel()
            labelProto.translatesAutoresizingMaskIntoConstraints = false
            labelProto.numberOfLines = 3
            labelProto.lineBreakMode = .byCharWrapping
            labelProto.font = defaultFont
            return labelProto
        }()
        
        static func estimatedLabelHeight(width: CGFloat, text: String) -> CGFloat {
            labelProto.frame = CGRect(x: 0.0, y: 0.0, width: width, height: CGFloat.greatestFiniteMagnitude)
            labelProto.text = text
            labelProto.sizeToFit()
            return labelProto.frame.height
        }
        
        let messageLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = labelProto.numberOfLines
            label.lineBreakMode = labelProto.lineBreakMode
            label.font = labelProto.font
            return label
        }()
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            
            super.init(style: .subtitle, reuseIdentifier: LogEntryCell.reuseIdentifier)
            
            backgroundColor = .white
            contentView.backgroundColor = .white
            
            contentView.addSubview(messageLabel)
            
            messageLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: LogEntryCell.padding)
                .isActive = true
            messageLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: LogEntryCell.padding)
                .isActive = true
            messageLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -LogEntryCell.padding)
                .isActive = true
            messageLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: contentView.bottomAnchor,
                constant: -LogEntryCell.padding)
                .isActive = true
        }
        
        required init?(coder: NSCoder) { fatalError() }
        
    }

#endif
