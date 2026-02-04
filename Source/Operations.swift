//
//  Operations.swift
//  Operations
//
//  Created by dev on 2/3/26.
//

import UIKit

final class ViewDelayedOperation: Operation {
    private var _block: (() -> Void)? = nil
    private var _delay: UInt = 0
    
    init(_ block: @escaping () -> Void, delayMs: UInt = 100) {
        super.init()
        _block = block
        _delay = delayMs
    }
    
    override func main() {
        Thread.sleep(forTimeInterval:Double(_delay) / 1000.0)
        if isCancelled {
            return
        }
        OperationQueue.main.addOperation {
            self._block?()
        }
    }
}
