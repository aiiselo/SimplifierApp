//
//  BookmarksViewController.swift
//  SimplifierApp
//
//  Created by Олеся Мартынюк on 07.03.2021.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class Bookmarks {
    var uuid: String?
    var preview: String?
    var simplification: String?
    var date: String?
    
    init(uuid:String, previewText:String, simpleText:String, date: String) {
        self.uuid = uuid
        self.preview = previewText
        self.simplification = simpleText
        self.date = date
    }
}

class SubtitleTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BookmarksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
       
    var tableView = UITableView()
    let identifier = "CELL_ID"
    let user = Auth.auth().currentUser
    let ref = Database.database().reference(fromURL: "https://textsimplifier-default-rtdb.firebaseio.com/")
    var favourites: [Bookmarks] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateListOfBookmarks()
        
//        ref.child("users").child(self.user!.uid).child("favourites").getData{
//            (error, snapshot) in
//                if let error = error {
//                        print("Error getting data \(error)")
//                    }
//                else if snapshot.exists() {
//                    if let snapshotValue = snapshot.value {
//                        for (uuid, dictionary) in snapshotValue as! Dictionary<String, Dictionary<String, String>> {
//                            self.favourites.append(Bookmarks(
//                                                    uuid: uuid,
//                                                    previewText: dictionary["preview_text"]!,
//                                                    simpleText: dictionary["simplified_text"]!,
//                                                    date: dictionary["date"]!))
//                        }
//                    }
//                }
//        }
//        self.tableView.reloadData()
        
//        ref.child("users").child(self.user!.uid).observeSingleEvent(of: .value, with: { (snapshotChild) in
//                   if snapshotChild.hasChild("favourites"){
//                    self.ref.child("users").child(self.user!.uid).child("favourites").observeSingleEvent(of: .value, with: {(snapshot) in
//                            if let snapshotValue = snapshot.value {
//                                for (uuid, dictionary) in snapshotValue as! Dictionary<String, Dictionary<String, String>>{
//                                    self.favourites.append(Bookmarks(uuid: uuid, previewText: dictionary["preview_text"]!, simpleText: dictionary["simplified_text"]!, date: dictionary["date"]!))
//                                }
//                                self.tableView.reloadData()
//                            }
//                        })
//                }})
        NotificationCenter.default.addObserver(self, selector: #selector(updateListOfBookmarks), name: .didUpdateBookmark, object: nil)

        self.tableView = UITableView(frame: view.bounds, style: .plain)
        self.tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: identifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(tableView)
        
    }

//    override func viewWillAppear(_ animated: Bool) {
//
//    }
    
    @objc func updateListOfBookmarks() {
        var newFavourites: [Bookmarks] = []
        self.ref.child("users").child(self.user!.uid).child("favourites").getData{
            (error, snapshot) in
                if let error = error {
                        print("Error getting data \(error)")
                    }
                else if snapshot.exists() {
                    if let snapshotValue = snapshot.value {
                        for (uuid, dictionary) in snapshotValue as! Dictionary<String, Dictionary<String, String>> {
                            newFavourites.append(Bookmarks(
                                                    uuid: uuid,
                                                    previewText: dictionary["preview_text"]!,
                                                    simpleText: dictionary["simplified_text"]!,
                                                    date: dictionary["date"]!))
                        }
                        self.favourites = newFavourites
                    }
                }
        }
    }
                            
    
    //MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.textLabel?.text = self.favourites[indexPath.row].preview
        cell.detailTextLabel?.text = self.favourites[indexPath.row].date
        return cell
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favourites.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showdetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [
                    makeDeleteContextualAction(forRowAt: indexPath)
                ])
    }
    
   func makeDeleteContextualAction(forRowAt indexPath: IndexPath) -> UIContextualAction {
        let deleteAction = UIContextualAction(style: .destructive, title: "delete") {
            (_, _, _) in
            self.favourites.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            if let user = self.user {
                let usersReference = self.ref.child("users").child(user.uid).child("favourites")
                usersReference.child(self.favourites[indexPath.row].uuid!).removeValue()
            }
        }
        return deleteAction
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailedViewController {
            destination.note = favourites[(tableView.indexPathForSelectedRow?.row)!]
            tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
    }
}

extension Notification.Name {
    static var didUpdateBookmark: Notification.Name {
        return Notification.Name("didUpdateBookmark")
    }
}
