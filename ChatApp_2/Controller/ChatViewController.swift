//
//  ChatViewController.swift
//  ChatApp_2
//
//  Created by 須藤英隼 on 2020/06/27.
//  Copyright © 2020 Eishun Sudo. All rights reserved.
//

import UIKit
import ChameleonFramework
import Firebase

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var sendButton: UIButton!
    
    //スクリーンのサイズ
    let screenSize = UIScreen.main.bounds.size
    
    var chatArray = [Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = selff
        tableView.dataSource = self
        messageTextField.delegate = self
        tableView.register(UINib(nibName: "CustomCell", bundle: nil), forCellReuseIdentifier: "Cell")
        //可変
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 75
        // Do any additional setup after loading the view.
        
        //キーボード
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardWillShow(_ :)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.keyboardwillHide(_ :)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //Firebaseからデータをフェッチ 取得
        fetchChatData()
        
        tableView.separatorStyle = .none
        
    }
    
    @objc func keyboardWillShow(_ notification:NSNotification) {
        
        let keyboardHeight = ((notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as Any) as AnyObject).cgRectValue.height
        
        messageTextField.frame.origin.y = screenSize.height - keyboardHeight - messageTextField.frame.height
        
    }
    
    @objc func keyboardwillHide(_ notification: NSNotification){
        
        messageTextField.frame.origin.y = screenSize.height -
            messageTextField.frame.height
        
        guard let rect = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else{return}
        
        UIView.animate(withDuration: duration) {
            let transform = CGAffineTransform(translationX: 0, y: 0)
            self.view.transform = transform
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        messageTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //メッセージの数
        return chatArray.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)  as! CustomCell
        
        cell.messageLabel.text = chatArray[indexPath.row].message

        //以下お手本ではuserNameLable
        cell.userName.text = chatArray[indexPath.row].sender
        cell.iconImageView.image = UIImage(named: "dogAvatarImage")
        
        if cell.userName.text == Auth.auth().currentUser?.email as! String{
            
            cell.messageLabel.backgroundColor = UIColor.flatGreen()
            
            //ボタンを丸くする
            cell.messageLabel.layer.cornerRadius = 20
            cell.messageLabel.layer.masksToBounds = true
            
        }else {
            
            cell.messageLabel.backgroundColor = UIColor.flatBlue()
            
        }
        
        cell.messageLabel.backgroundColor = UIColor.flatGreen()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
    
    //送信ボタン実装
    @IBAction func sendAction(_ sender: Any) {
        
        messageTextField.endEditing(true)
        messageTextField.isEnabled = false
        sendButton.isEnabled = false
        
        //文字数15文字 制限
        if messageTextField.text!.count > 15 {
            print("注意!15文字以上です！")
            return
        }
        
        let chatDB = Database.database().reference().child("chats")
        //キーバリュー型で内容を送信(dictionary)
        let messageInfo = ["sender": Auth.auth().currentUser?.email, "message": messageTextField.text!]
        
        //chatDBに入れる
        chatDB.childByAutoId().setValue(messageInfo) { (error, result) in
            if error  != nil {
                print(error)
            }else {
                print("送信完了")
                self.messageTextField.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextField.text = ""
            }
        }
        
    }
    
    //firebaseからデータ取得、つまりフェッチのメソッド作成
    func fetchChatData() {
        //どこからデータを引っ張ってくるのか？
        let fetchDataRef = Database.database().reference().child("chats")
        
        //新しく更新があったときだけ取得した
        fetchDataRef.observe(.childAdded) { (snapShot) in
            
            //以下　if !=nil としないのか？
            let snapShotData = snapShot.value as! AnyObject
            let text = snapShotData.value(forKey: "message")
            let sender = snapShotData.value(forKey: "sender")
            let message = Message()
            message.message = text as! String
            message.sender = sender as! String
            self.chatArray.append(message)
            self.tableView.reloadData()
            
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
