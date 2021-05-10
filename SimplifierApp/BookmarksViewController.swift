//
//  BookmarksViewController.swift
//  SimplifierApp
//
//  Created by Олеся Мартынюк on 07.03.2021.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase

class Bookmarks {
    var preview: String?
    var simplification: String?

    init(previewText:String, simpleText:String) {
        self.preview = previewText
        self.simplification = simpleText
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
    let ref = Database.database().reference(fromURL: "https://textsimplifier-default-rtdb.firebaseio.com/")
    let user = Auth.auth().currentUser
    var favourites: [Bookmarks] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref.child("users").child(self.user!.uid).observeSingleEvent(of: .value, with: { (snapshotChild) in
           if snapshotChild.hasChild("favourites"){
            self.ref.child("users").child(self.user!.uid).child("favourites").observeSingleEvent(of: .value, with: {(snapshot) in
                    if let snapshotValue = snapshot.value {
                        for (key, value) in snapshotValue as! Dictionary<String, String>{
                            self.favourites.append(Bookmarks(previewText: key, simpleText: value))
                        }
                        self.tableView.reloadData()
                    }
                })
        }})
        
        self.tableView = UITableView(frame: view.bounds, style: .plain)
        self.tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: identifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(tableView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.favourites.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        cell.textLabel?.text = self.favourites[indexPath.row].preview
        return cell
        }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "delete") {
            (action, indexPath) in
            self.favourites.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        if let user = self.user {
            let usersReference = self.ref.child("users").child(user.uid).child("favourites")
            usersReference.child(self.favourites[indexPath.row].preview!).removeValue()
        }
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showdetail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailVC {
            destination.note = favourites[(tableView.indexPathForSelectedRow?.row)!]
            tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
    }
}
