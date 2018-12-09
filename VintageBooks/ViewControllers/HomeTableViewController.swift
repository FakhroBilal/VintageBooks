//
//  HomeTableViewController.swift
//  VintageBooks
//
//  Created by Bilal Fakhro on 2018-12-03.
//  Copyright © 2018 Bilal Fakhro. All rights reserved.
//

import UIKit
import Firebase

class HomeTableViewController: UITableViewController {

    let homeCellID = "homeCellID"
    var posts = [Post]()
    
    var ref: DatabaseReference?
    let userID = Auth.auth().currentUser?.uid

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // REGISTER THE CLASS FOR THE CELL
        tableView.register(postCell.self, forCellReuseIdentifier: homeCellID)
        fetchPost()
    }
    
    // DOWNLOAD THE DATA FROM FIREBASE DATABASE
    func fetchPost() {
        let ref = Database.database().reference()
        ref.child("Posts").observe(.childAdded) { (snapshot: DataSnapshot) in
            if let Dictionary = snapshot.value as? [String: Any] {
                let post = Post(Dictionary: Dictionary)
                self.posts.append(post)
                
                DispatchQueue.main.async(execute: {
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    // HOW MANY ROWS IS NEEDED IN THE TABLEVIEW
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell  {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: homeCellID, for: indexPath) as! postCell
        let posten = posts[indexPath.row]

        cell.textLabel?.text = posts[indexPath.row].bookTitle
        cell.detailTextLabel?.text = posts[indexPath.row].bookText

        if let bookPhotoUrl = posten.bookPhotoUrl {
            cell.bookImageView.loadImageUsingCacheWithUrlString(bookPhotoUrl)
            }
        return cell
    }
    
    // CELL ROW HEIGHT
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let booksDetailView = storyboard?.instantiateViewController(withIdentifier: "BooksDetailViewController") as? BooksDetailViewController
        
        let postens = posts[indexPath.row]
        booksDetailView?.bookTitleString = posts[indexPath.row].bookTitle!
        booksDetailView?.bookText = posts[indexPath.row].bookText!
        
        let bookImageView = UIImageView()
        if let booksPhotoUrl = postens.bookPhotoUrl {
           bookImageView.loadImageUsingCacheWithUrlString(booksPhotoUrl)
        }
        booksDetailView?.bookImage = bookImageView.image!
        self.navigationController?.pushViewController(booksDetailView!, animated: true)
    }
    
    @IBAction func logOutButtonTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let storyboard = UIStoryboard(name: "Start", bundle: nil)
        let signInVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")
        self.present(signInVC, animated: false, completion: nil)
    }
}

// CLASS FOR THE CELL FOR THE POSTLABELS
class postCell: UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // TEXTLABEL & DETAILLABEL CONSTRAINT AND MARGIN
        textLabel?.frame = CGRect(x: 80, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 80, y: detailTextLabel!.frame.origin.y + 2, width: 320, height: detailTextLabel!.frame.height)
    }
    // IMAGEVIEW LAYOUTS AND CONSTRAINS
    let bookImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 32
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(bookImageView)
        
        // BOOKIMAGE CONSTRIANT
        bookImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        bookImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        // WIDTH AND HEIGHT FOR THE IMAGEVIEW.IMAGE
        bookImageView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        bookImageView.heightAnchor.constraint(equalToConstant: 64).isActive = true

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

