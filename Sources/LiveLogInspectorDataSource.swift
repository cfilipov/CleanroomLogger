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
        
        struct BufferItem {
            let entry: LogEntry
            let message: String
            
            init(_ i: (LogEntry, String)) {
                (self.entry, self.message) = i
            }
        }
        
        public enum SortOrder {
            case asc
            case desc
        }
        
        private enum ScrollTarget {
            case top
            case bottom
            case auto
        }
        
        fileprivate var items: [BufferItem] = []
        
        fileprivate var count: Int {
            return items.count
        }
        
        private func translate(index: Int) -> Int {
            return order == .asc ? index : items.count - 1 - index
        }
        
        fileprivate subscript(index: Int) -> BufferItem {
            get {
                return items[translate(index: index)]
            }
        }
        
        fileprivate func truncate() {
            items.remove(at: 0)
        }
        
        fileprivate func add(_ i: (LogEntry, String)) {
            items.append(BufferItem(i))
        }
        
        fileprivate func set(_ ix: [(LogEntry, String)]) {
            items = ix.map(BufferItem.init)
        }
        
        public var paused: Bool = false {
            didSet {
                if !paused {
                    reload()
                }
            }
        }
        
        private let recorder: BufferedLogEntryMessageRecorder
        private var recordItemCallbackHandle: CallbackHandle?
        private var clearBufferCallbackHandle: CallbackHandle?
        private var topIndexPath = IndexPath(row: 0, section: 0)
        
        fileprivate let dateFormatter: DateFormatter = {
            let f = DateFormatter()
            f.dateStyle = .none
            f.setLocalizedDateFormatFromTemplate("jmsSSS")
            return f
        }()
        
        private var bottomIndexPath: IndexPath {
            return IndexPath(row: max(count - 1, 0), section: 0)
        }
        
        private var newestIndexPath: IndexPath {
            return IndexPath(row: order == .asc ? max(count - 1, 0) : 0, section: 0)
        }
        
        private var oldestIndexPath: IndexPath {
            return IndexPath(row: order == .asc ? 0 : max(count - 1, 0), section: 0)
        }
        
        public weak var tableView: UITableView? = nil {
            didSet {
                guard let tableView = tableView else { fatalError() }
                LogEntryCell.register(tableView)
                tableView.delegate = self
                tableView.dataSource = self
                tableView.separatorStyle = .none
                reload()
                
                clearBufferCallbackHandle = recorder.addCallback(didClearBuffer: { _ in
                    DispatchQueue.main.async { [unowned self] in
                        self.reload()
                    }
                })
                
                recordItemCallbackHandle = recorder.addCallback(didRecordBufferItem: { _, item, didTruncate in
                    
                    guard !self.paused
                        else { return }
                    
                    guard item.0.severity >= self.minimumSeverity
                        else { return }
                    
                    DispatchQueue.main.sync { [unowned self] in
                        
                        tableView.beginUpdates()
                        
                        if didTruncate {
                            precondition(self.recorder.bufferLimit > 0)
                            self.truncate()
                            tableView.deleteRows(at: [self.oldestIndexPath], with: .fade)
                        }
                        
                        self.add(item)
                        tableView.insertRows(at: [self.newestIndexPath], with: .fade)
                        tableView.endUpdates()
                        if self.shouldAutoScroll { self.scroll(to: .auto) }
                    }

                })
            }
        }
        
        public var order: SortOrder = .asc {
            didSet {
                reload(forceScroll: true)
            }
        }
        
        public var minimumSeverity: LogSeverity = .verbose {
            didSet {
                reload()
            }
        }
        
        init(recorder: BufferedLogEntryMessageRecorder) {
            self.recorder = recorder
        }
        
        private func scroll(to position: ScrollTarget) {
            guard count > 0
                else { return }
            
            switch position {
            case .top:
                tableView?.scrollToRow(at: topIndexPath, at: .top, animated: true)
            case .bottom:
                tableView?.scrollToRow(at: bottomIndexPath, at: .bottom, animated: true)
            case .auto:
                switch order {
                case .asc: scroll(to: .bottom)
                case .desc: scroll(to: .top)
                }
            }
        }
        
        private var shouldAutoScroll: Bool {
            return order == .asc && !paused
        }
        
        fileprivate func reload(forceScroll: Bool = false) {
            let items = minimumSeverity > .verbose
                ? recorder.buffer.filter { $0.0.severity >= self.minimumSeverity }
                : recorder.buffer
            set(items)
            tableView?.reloadData()
            if shouldAutoScroll || forceScroll { self.scroll(to: .auto) }
        }
        
    }
    
    extension String {
        func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
            let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
            let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
            return boundingBox.height
        }
    }
    
    extension LiveLogInspectorDataSource: UITableViewDataSource, UITableViewDelegate {
        
        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
            -> Int {
                
                guard section == 0
                    else { return 0 }
                return count
        }
        
        public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
            -> UITableViewCell {
                
                precondition(indexPath.section == 0)
                let item = self[indexPath.row]
                let cell = LogEntryCell.dequeue(tableView, for: indexPath)
                cell.selectionStyle = .none
                cell.messageLabel.text = item.message
                cell.messageLabel.textColor = item.entry.severity.textColor
                cell.contentView.backgroundColor = item.entry.severity.backgroundColor
                return cell
        }
        
        public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            precondition(indexPath.section == 0)
            
            let item = self[indexPath.row]
            let width = UIScreen.main.bounds.width - (LogEntryCell.padding * 2)
            let height = item.message.heightWithConstrainedWidth(
                width: width,
                font: LogEntryCell.defaultFont)
            return height + (LogEntryCell.padding * 2)
        }
        
        public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
            var actions = [UITableViewRowAction]()
            let item = self[indexPath.row]
            let timestamp = dateFormatter.string(from: item.entry.timestamp)
            let action = UITableViewRowAction(style: .normal, title: timestamp) { (action, indexPath) -> Void in
                tableView.setEditing(false, animated: true)
            }
            actions.append(action)
            return actions
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
        static var padding = CGFloat(8)
        
        static func register(_ tableView: UITableView) {
            tableView.register(self, forCellReuseIdentifier: reuseIdentifier)
        }
        
        static func dequeue(_ tableView: UITableView, for indexPath: IndexPath) -> LogEntryCell {
            return tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LogEntryCell
        }
        
        let messageLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.lineBreakMode = .byTruncatingTail
            label.font = defaultFont
            return label
        }()
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            
            super.init(style: .default, reuseIdentifier: LogEntryCell.reuseIdentifier)
            
            backgroundColor = .white
            contentView.backgroundColor = .white
            contentView.addSubview(messageLabel)
            
            messageLabel.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: LogEntryCell.padding)
                .isActive = true
            messageLabel.leftAnchor.constraint(
                equalTo: contentView.leftAnchor,
                constant: LogEntryCell.padding)
                .isActive = true
            messageLabel.rightAnchor.constraint(
                equalTo: contentView.rightAnchor,
                constant: -LogEntryCell.padding)
                .isActive = true
            messageLabel.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -LogEntryCell.padding)
                .isActive = true
        }
        
        required init?(coder: NSCoder) { fatalError() }
        
    }

#endif
