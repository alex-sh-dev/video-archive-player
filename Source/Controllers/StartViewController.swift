//
//  ViewController.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/22/26.
//

import UIKit

private enum ParseError {
    case parseFailed
    case jsonLoadFailed
    case urlEmpty
    case urlInvalid
    case jsonDataEmpty
    
    func desc() -> String {
        switch (self) {
        case .jsonLoadFailed:
            return "JSON load failed!"
        case .parseFailed:
            return "JSON parse failed!"
        case .urlEmpty:
            return "Json url empty!"
        case .urlInvalid:
            return "Json url invalid!"
        default:
            return "Json data is empty or part is missing!"
        }
    }
}

class StartViewController: UIViewController {
    @IBOutlet weak var jsonUrlTextField: UITextField!
    @IBOutlet weak var startPlayerButton: UIButton!
    
    private var videoFileList: VideoFileList = VideoFileList()
    private var name = ""
    private var date: Date = Date.now
    private var videoSize: CGSize = .zero
    
    @IBAction func startPlayerTapped(_ sender: Any) {
        self.startPlayerButton.isEnabled = false
        startParser()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let playerVC = segue.destination.children.first as? PlayerViewController else {
            return
        }
        
        playerVC.videoFileList = videoFileList
        playerVC.videoSize = videoSize
        
        let subtitle = date.formatted(date: .long, time: .omitted)
        let titleView = TitleView(title: name, subtitle: subtitle)
        playerVC.navigationItem.titleView = titleView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func startParser() {
        if jsonUrlTextField.text!.isEmpty {
            showAlert(for: .urlEmpty)
            return
        }
        
        guard let url = URL(string: self.jsonUrlTextField.text!) else {
            showAlert(for: .urlInvalid)
            return
        }
        
        URLSession.shared.dataTask(with: url) {
            [unowned self] (data, response, error) -> Void in
            if error == nil && data != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: Any]
                    
                    if let name = json["name"] as? String {
                        self.name = name
                    }
                    
                    if let dateStr = json["date"] as? String {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "ddMMyyyy"
                        self.date = dateFormatter.date(from: dateStr) ?? Date.distantPast
                    }
                   
                    if let videoSizeStr = json["video_size"] as? String {
                        let sizeList = videoSizeStr.split(separator: "x")
                        if sizeList.count > 1 {
                            let w = Int(sizeList[0]) ?? 0
                            let h = Int(sizeList[1]) ?? 0
                            self.videoSize = w > 0 && h > 0 ? CGSize(width: w, height: h) : .zero
                        }
                    }
                    
                    if let paths = json["paths"] as? Array<Dictionary<String, Any>> {
                        for path in paths {
                            guard let url = path["url"] as? String else {
                                continue
                            }
                            
                            let time = path["time"] as? UInt ?? 0
                            
                            guard let duration = path["duration"] as? UInt else {
                                continue
                            }
                            
                            self.videoFileList.append(time: time, duration: duration, path: url)
                        }
                    }
                    DispatchQueue.main.async { self.parseFinished() }
                } catch {
                    DispatchQueue.main.async { self.parseFailed(.parseFailed) }
                }
            } else {
                DispatchQueue.main.async { self.parseFailed(.jsonLoadFailed) }
            }
        }.resume()
    }
    
    private func parseFinished() {
        self.startPlayerButton.isEnabled = true
        if self.videoFileList.count == 0 {
            showAlert(for: .jsonDataEmpty)
            return
        }
        self.performSegue(withIdentifier: PlayerViewController.className, sender: self)
    }
    
    private func parseFailed(_ error: ParseError) {
        self.startPlayerButton.isEnabled = true
        self.showAlert(for: error)
    }
    
    private func showAlert(for error: ParseError) {
        self.startPlayerButton.isEnabled = true
        let alert = UIAlertController(title: "Error", message: error.desc(), preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
