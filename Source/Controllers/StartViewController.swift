//
//  ViewController.swift
//  VideoArchivePlayer
//
//  Created by dev on 1/22/26.
//

import UIKit

class StartViewController: UIViewController, VideoMetaDataParserDelegate {
    @IBOutlet weak var jsonUrlTextField: UITextField!
    @IBOutlet weak var startPlayerButton: UIButton!
    
    private var _parser = VideoMetaDataParser()
    private var _parseResult: VideoMetaDataParseResult?
    
    @IBAction func startPlayerTapped(_ sender: Any) {
        self.startPlayerButton.isEnabled = false
        _parser.start(for: self.jsonUrlTextField.text!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let playerVC = segue.destination.children.first as? PlayerViewController else {
            return
        }
        
        guard let result = _parseResult else {
            return
        }
        
        playerVC.videoFileList = result.videoFileList
        playerVC.videoSize = result.videoSize
        
        let subtitle = result.date.formatted(date: .long, time: .omitted)
        let titleView = TitleView(title: result.name, subtitle: subtitle)
        playerVC.navigationItem.titleView = titleView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _parser.delegate = self
    }
    
    private func showAlert(for error: ParseError) {
        let alert = UIAlertController(title: "Error", message: error.desc(), preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: VideoMetaDataParserDelegate
    
    func parseFinished(result: VideoMetaDataParseResult) {
        self.startPlayerButton.isEnabled = true
        _parseResult = result
        self.performSegue(withIdentifier: PlayerViewController.className, sender: self)
    }
    
    func parseFailed(err: ParseError) {
        self.startPlayerButton.isEnabled = true
        self.showAlert(for: err)
    }
}
