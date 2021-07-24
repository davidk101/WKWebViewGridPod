//
//  WindowController.swift
//  wkwebviewgrid
//
//  Created by David Kumar on 7/24/21.
//

import Cocoa

class WindowController: NSWindowController {

    @IBOutlet weak var addressEntry: NSTextField!
    override func windowDidLoad() {
        super.windowDidLoad()
        window?.titleVisibility = .hidden // toolbar moved up to window traffic lights
    }
    
    // change window first responder after 'escape' key triggered
    override func cancelOperation(_ sender: Any?) {
        
        window?.makeFirstResponder(self.contentViewController)
    }
}
