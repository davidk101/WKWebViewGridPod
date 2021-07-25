//
//  ViewController.swift
//  wkwebviewgrid
//
//  Created by David Kumar on 7/24/21.
//

import Cocoa
import WebKit

extension NSTouchBarItem.Identifier {
    
    static let navigation = NSTouchBarItem.Identifier("david-kumar.wkwebviewgrid.navigation") // bundle_identifier.id
    static let enterAddress = NSTouchBarItem.Identifier("david-kumar.wkwebviewgrid.enterAddress")
    static let sharingPicker = NSTouchBarItem.Identifier("david-kumar.wkwebviewgrid.sharingPicker")
    static let adjustGrid = NSTouchBarItem.Identifier("david-kumar.wkwebviewgrid.adjustGrid")
    static let adjustRows = NSTouchBarItem.Identifier("david-kumar.wkwebviewgrid.adjustRows")
    static let adjustCols = NSTouchBarItem.Identifier("david-kumar.wkwebviewgrid.adjustCols")
    
}

class ViewController: NSViewController, WKNavigationDelegate, NSGestureRecognizerDelegate, NSTouchBarDelegate {
    // every wkwebview must have a Core Animation layer behind it since macOS does not have that already
    // identifier -> control -> add to NSTouchBar
    // no API to detect if touch bar present -> INTENTIONAL -> no exclusivity
    
    var rows: NSStackView!
    var selectedWebView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create the stackView and add it to view
        rows = NSStackView()
        rows.orientation = .vertical
        rows.distribution = .fillEqually
        rows.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rows)
    
        // create auto layout constraints
        rows.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        rows.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        rows.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        rows.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        // create initial column with web view
        let column = NSStackView(views: [makeWebView()])
        column.distribution = .fillEqually
        
        // add column to rows stack view
        rows.addArrangedSubview(column)

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @IBAction func urlEntered(_ sender: NSTextField) {
        // ensure web view selected
        guard let selected = selectedWebView else { return }
        
        // convert string for URL Request
        if let url = URL(string: sender.stringValue) {
            selected.load(URLRequest(url: url))
        }
    }
    
    @IBAction func navigationClicked(_ sender: NSSegmentedControl) {
        // ensure web view selected
        guard let selected = selectedWebView else { return }
        if sender.selectedSegment == 0 { // back requested
            selected.goBack()
            
        } else { // forward requested
            selected.goForward()
        }
    }
    
    @IBAction func adjustRows(_ sender: NSSegmentedControl) {
        
        if sender.selectedSegment == 0 { // add row
                    
            // count how many columns we have so far
            let columnCount = (rows.arrangedSubviews[0] as! NSStackView).arrangedSubviews.count
            
            // make a new array of web views that contain the correct number of columns
            let viewArray = (0 ..< columnCount).map { _ in makeWebView() }

            // use that web view to create a new stack view
            let row = NSStackView(views: viewArray)

            row.distribution = .fillEqually
            rows.addArrangedSubview(row)
            
        } else {
            //ensure at least two rows
            guard rows.arrangedSubviews.count > 1 else {
                return
            }
            // pull out the final row, and make sure its a stack view
            guard let rowToRemove = rows.arrangedSubviews.last as? NSStackView else { return }
            // remove webview from screemn
            for cell in rowToRemove.arrangedSubviews {
                cell.removeFromSuperview()
                
            }
            // remove the whole stack view row
            rows.removeArrangedSubview(rowToRemove)
        }
    }
    
    @IBAction func adjustColumns(_ sender: NSSegmentedControl) {
        
        if sender.selectedSegment == 0 { // add column
            for case let row as NSStackView in rows.arrangedSubviews {
                row.addArrangedSubview(makeWebView())
            }
        }
        else { // remove column
            guard let firstRow = rows.arrangedSubviews.first as? NSStackView else {
                return
            }
            // ensure tow columns
            guard firstRow.arrangedSubviews.count > 1 else { return }
            // safe to delete a column
            for case let row as NSStackView in rows.arrangedSubviews {
                // loop over every row
                if let last = row.arrangedSubviews.last {
                    // remove lst web view in the column
                    row.removeView(last)
                    last.removeFromSuperview()
                }
            }
        }
    }
        
    func makeWebView() -> NSView {
            
        let webView = WKWebView()
        webView.navigationDelegate = self
        webView.wantsLayer = true // for the added CA layer
        webView.load(URLRequest(url: URL(string: "https://www.davidkumar.tech")!)) // app transport security exemption may be needed here
        
        // add gesture recognizer delegate
        let recognizer = NSClickGestureRecognizer(target: self, action: #selector(webViewClicked))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
        
        // defaults the webview to the first one generated
        if selectedWebView == nil {
            select(webView: webView)
        }
            
        return webView
            
    }
    
    func select(webView: WKWebView) {
        
        selectedWebView = webView
        selectedWebView.layer?.borderWidth = 2
        selectedWebView.layer?.borderColor = NSColor.green.cgColor
        
        // retrieving web address String
        if let WindowController = view.window?.windowController as? WindowController {
            
            WindowController.addressEntry.stringValue = selectedWebView.url?.absoluteString ?? "" // nil coalescing
        }
        
    }
    
    @objc func webViewClicked(recognizer: NSClickGestureRecognizer) {
        
        // get the web view that triggered the gesture recoginzer
        guard let newSelectedWebView = recognizer.view as? WKWebView else { return }
        // deselect the currently selected web view if there is one
        if let selected = selectedWebView {
            selected.layer?.borderWidth = 0
        }
        // select the new view
        select(webView: newSelectedWebView)
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: NSGestureRecognizer, shouldAttemptToRecognizeWith event: NSEvent) -> Bool {
        
        if gestureRecognizer.view == selectedWebView{
            return false
        }
        else{
            return true
        }
    }
    
    // called every time web content loads
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        
        guard webView == selectedWebView else { return }
        
        // updates address URL when website changes using the delegate
        if let WindowController = view.window?.windowController as? WindowController {
            WindowController.addressEntry.stringValue = selectedWebView.url?.absoluteString ?? ""
        }
        
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        
        switch identifier {
            
        case NSTouchBarItem.Identifier.enterAddress:
            
            let button = NSButton(title: "Search or enter website name", target: self, action: #selector(selectedAddressEntry))
            button.setContentHuggingPriority(NSLayoutConstraint.Priority(rawValue: 10), for: .horizontal) // priority given to button's size
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            
            customTouchBarItem.view = button
            return customTouchBarItem
            
        case NSTouchBarItem.Identifier.navigation:
            
            // backward and forward images
            let back = NSImage(named: NSImage.Name("touchBarGoBackTemplate"))!
            let forward = NSImage(named: NSImage.Name("touchBarGoForwardTemplate"))!
            
            // create segmented control
            let segmentedControl = NSSegmentedControl(images: [back, forward], trackingMode: .momentary, target: self, action: #selector(navigationClicked))
            
            // wrap that inside a Touch Bar item
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            customTouchBarItem.view = segmentedControl

            return customTouchBarItem
            
        case NSTouchBarItem.Identifier.adjustGrid:
            
            let popOver = NSPopoverTouchBarItem(identifier: identifier) // nested touch bar items
            popOver.collapsedRepresentationLabel = "Grid"
            popOver.customizationLabel = "Adjust Grid"
            popOver.popoverTouchBar = NSTouchBar()
            popOver.popoverTouchBar.delegate = self
            popOver.popoverTouchBar.defaultItemIdentifiers = [.adjustRows, .adjustCols]
            
            return popOver
            
        case NSTouchBarItem.Identifier.adjustRows:
            
            let control = NSSegmentedControl(labels: ["Row++", "Row--"], trackingMode: .momentaryAccelerator, target: self, action: #selector(adjustRows))
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            customTouchBarItem.customizationLabel = "Row"
            customTouchBarItem.view = control
            
            return customTouchBarItem
            
        case NSTouchBarItem.Identifier.adjustCols:
            let control = NSSegmentedControl(labels: ["Col++", "Col--"], trackingMode: .momentaryAccelerator, target: self, action: #selector(adjustColumns))
            let customTouchBarItem = NSCustomTouchBarItem(identifier: identifier)
            customTouchBarItem.customizationLabel = "Col"
            customTouchBarItem.view = control
            
            return customTouchBarItem
        
        default:
            return nil
        }
        
    }
    
    @objc func selectedAddressEntry() {
        
        if let windowController = view.window?.windowController as? WindowController {
            windowController.window?.makeFirstResponder(windowController.addressEntry) // primary responder
        }
    }
    
    override func makeTouchBar() -> NSTouchBar? { // necessary to override
        
        // enable custom touch bar
        NSApp.isAutomaticCustomizeTouchBarMenuItemEnabled = true
        
        // touch bar with ViewController as delegate
        let touchBar = NSTouchBar()
        touchBar.customizationIdentifier = NSTouchBar.CustomizationIdentifier("david-kumar.wkwebviewgrid")
        touchBar.delegate = self
        
        touchBar.defaultItemIdentifiers = [.navigation, .adjustGrid, .enterAddress, .sharingPicker]
        touchBar.principalItemIdentifier = .enterAddress
        touchBar.customizationAllowedItemIdentifiers = [.adjustGrid, .adjustCols, .adjustRows]
        touchBar.customizationRequiredItemIdentifiers = [.enterAddress]

        return touchBar
    }
}

