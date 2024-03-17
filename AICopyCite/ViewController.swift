//
//  ViewController.swift
//  AICopyCite
//
//  Created by Heaven Chou on 2024/1/27.
//

import Cocoa
import WebKit

class ViewController: NSViewController {

    @IBOutlet weak var splitView: NSSplitView!
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var edText: NSTextField!
    @IBOutlet weak var edResult: NSTextField!
    
    @IBOutlet weak var rbNewSite: NSButton!
    
    @IBOutlet weak var rbOldSite: NSButton!
    
    let urlOldSite=URL(string: "https://old.gj.cool/gjcool/index")
    let urlNewSite=URL(string: "https://ocr.gj.cool/punct")
    
    var headStr: String = ""
    var midStr: String = ""
    var tailStr: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        splitView.setPosition(410, ofDividerAt: 0)
        
        let myRequest = URLRequest(url: urlNewSite!)
        webView.load(myRequest)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        //view.window?.maxFullScreenContentSize
        view.window?.zoom(self)
        view.window?.title = "引用複製自動新標"
    }
    
    // 將文字貼在編輯欄位中
    @IBAction func btPaste(_ sender: Any) {
        let pasteboard = NSPasteboard.general
        let str = pasteboard.string(forType: .string) ?? ""
        edText.stringValue = str
        
    }
    // 貼上新標網頁
    @IBAction func btRun(_ sender: Any) {
        
        // 先取得引用複製內容
        let copycite = edText.stringValue
        
        // 分解成三份
        // 《xx經》卷x：「如是我聞一時佛在舍衛國祇樹給孤獨園」(CBETA.....)
        
        let index = copycite.firstIndex(of: "「")    // 找到 3 的位置
        let index2 = copycite.lastIndex(of: "」")
        if index != nil && index2 != nil {
            headStr = String(copycite[...index!])
            midStr = String(copycite[copycite.index(after: index!)...copycite.index(before: index2!)])
            tailStr = String(copycite[index2!...])
        } else {
            _ = showMessage(title: "格式錯誤", message: "引用複製文字格式錯誤")
            return
        }
        
        if rbNewSite.state == .on {
            let strJS = "document.getElementById('PunctArea').innerText = '\(midStr)'"
            webView.evaluateJavaScript(strJS)
        } else {
            let strJS = "document.getElementById('origin000').innerText = '\(midStr)'"
            webView.evaluateJavaScript(strJS)
        }
        
    }

    // 網頁執行新標
    @IBAction func btPunct(_ sender: Any) {
        if rbNewSite.state == .on {
            let strJS = "punct_pro();"
            webView.evaluateJavaScript(strJS)
        } else {
            let strJS = "processHandler();"
            webView.evaluateJavaScript(strJS)
        }
    }
    
    // 複製文字
    @IBAction func btGetText(_ sender: Any) {
        if rbNewSite.state == .on {
            //let strJS = "copyText();"
            let strJS = "$('#copy-btn').trigger('click');"
            webView.evaluateJavaScript(strJS)
        } else {
            let strJS = "copyTxt();"
            webView.evaluateJavaScript(strJS)
        }
    }
    
    // 組成結果
    @IBAction func btGetResult(_ sender: Any) {
        
        let pasteboard = NSPasteboard.general
        var newMidStr = pasteboard.string(forType: .string) ?? ""
        // 去除最後的換行
        if newMidStr[newMidStr.index(before: newMidStr.endIndex)] == "\n" {
            // 刪除前後空白

            newMidStr = newMidStr.trimmingCharacters(in: .whitespaces)
        }
        // 把 [a01] 換回 [A01]
        newMidStr = newMidStr.replacingOccurrences(of: #"\[a(\d+)\]"#, with: "[A$1]", options: .regularExpression)
        
        let resultStr = headStr + newMidStr + tailStr
        edResult.stringValue = resultStr
        
        pasteboard.setString(resultStr, forType: .string)
    }
    
    // 選擇新站
    @IBAction func rbNewSiteClick(_ sender: Any) {
        if rbOldSite.state == .on {
            rbOldSite.state = .off
            let myRequest = URLRequest(url: urlNewSite!)
            webView.load(myRequest)
        }
    }
    
    // 選擇舊站
    @IBAction func rbOldSiteClick(_ sender: Any) {
        if rbNewSite.state == .on {
            rbNewSite.state = .off
            let myRequest = URLRequest(url: urlOldSite!)
            webView.load(myRequest)
        }
    }
    
    // 秀出訊息
    func showMessage(title: String, message: String, style: NSAlert.Style = .informational) -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = title
        myPopup.informativeText = message
        myPopup.alertStyle = style
        myPopup.addButton(withTitle: "確定")
        if style == .warning {
            myPopup.addButton(withTitle: "取消")
        }
        return myPopup.runModal() == .alertFirstButtonReturn
    }
}


