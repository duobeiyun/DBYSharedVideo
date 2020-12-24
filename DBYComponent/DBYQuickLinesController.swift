//
//  DBYQuickLinesController.swift
//  DBYSharedVideo
//
//  Created by 钟凡 on 2020/12/23.
//

import UIKit
import DBYSDK_dylib

class DBYQuickLinesController: UIViewController {
    lazy var lines: [DBYPlayLine] = [DBYPlayLine]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var reuseId: String = "DBYLineCell"
    
    @IBOutlet weak var contentView: UIView! {
        didSet {
            contentView.setRoundCorner(radius: 4)
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            let bundle = Bundle(for: Self.self)
            let nib = UINib(nibName: reuseId, bundle: bundle)
            tableView.register(nib, forCellReuseIdentifier: reuseId)
            tableView.rowHeight = 44
        }
    }
    @IBOutlet weak var closeButton: UIButton!
    
    @IBAction func close(sender: UIButton) {
        DBYQuickLinesController.dismiss()
    }
    
    public convenience init() {
        let cla = Self.self
        self.init(nibName: "\(cla)", bundle: Bundle(for: cla))
        modalPresentationStyle = .custom
        modalTransitionStyle = .crossDissolve
    }
}
extension DBYQuickLinesController {
    private static let shared = DBYQuickLinesController()
    static func show(lines: [DBYPlayLine]) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        window.addSubview(shared.view)
        shared.view.frame = window.bounds
        shared.lines = lines
    }
    /// after in seconds
    static func dismiss(after: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + after) {
            shared.view.removeFromSuperview()
        }
    }
    static func dismiss() {
        shared.view.removeFromSuperview()
    }
}
extension DBYQuickLinesController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId) as! DBYLineCell
        cell.label.text = lines[indexPath.row].name
        
        return cell
    }
}
extension DBYQuickLinesController: UITableViewDelegate {
    
}
