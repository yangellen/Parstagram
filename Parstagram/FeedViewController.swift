//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Ellen Yang on 3/18/21.
//

import UIKit
import Parse
import AlamofireImage

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

   @IBOutlet weak var tableView: UITableView!

   var posts = [PFObject]()
   var refreshControl: UIRefreshControl!
   var numberOfPost: Int!
   
   override func viewDidLoad() {
        super.viewDidLoad()

      tableView.delegate = self
      tableView.dataSource = self
        // Do any additional setup after loading the view.
      refreshControl = UIRefreshControl()
      refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
      tableView.insertSubview(refreshControl, at: 0)

   }

   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)

      numberOfPost = 20

      let query = PFQuery(className: "Post")
      query.order(byDescending: "createdAt")
      query.includeKeys(["author", "comments", "comments.author"])
      query.limit = numberOfPost

      query.findObjectsInBackground { (posts, error) in
         if posts != nil{
            self.posts = posts!
            self.tableView.reloadData()
         }
      }

   }

   //function to load more posts
   func loadMorePosts(){
      numberOfPost = numberOfPost + 20

      let query = PFQuery(className: "Post")
      query.order(byDescending: "createdAt")
      query.includeKeys(["author", "comments", "comments.author"])
      query.limit = numberOfPost

      query.findObjectsInBackground { (posts, error) in
         if posts != nil{
            self.posts = posts!
            self.tableView.reloadData()
         }
      }

   }

   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      let post = posts[section]
      let comments = (post["comments"] as? [PFObject]) ?? []
      return comments.count + 1
   }

   func numberOfSections(in tableView: UITableView) -> Int {
      return posts.count
   }

   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

      let post = posts[indexPath.section]
      let comments = (post["comments"] as? [PFObject]) ?? []

      if indexPath.row == 0 {
         let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell

         let user = post["author"] as! PFUser
         cell.usernameLabel.text = user.username
         cell.captionLabel.text = post["caption"] as? String

         let imageFile = post["image"] as! PFFileObject
         let urlString = imageFile.url!
         let url = URL(string: urlString)!

         cell.photoView.af.setImage(withURL: url)

         return cell
      }else{
         let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell

         let comment = comments[indexPath.row - 1]
         cell.commentLabel.text = comment["text"] as? String

         let user = comment["author"] as! PFUser
         cell.nameLabel.text = user.username

         return cell
      }

   }

   @objc func onRefresh() {
      run(after: 2) {
             self.refreshControl.endRefreshing()
          }
   }

   // Implement the delay method
   func run(after wait: TimeInterval, closure: @escaping () -> Void) {
       let queue = DispatchQueue.main
       queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
   }

   //when user gets the end of page, will load more posts
   func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
         if indexPath.row + 1 == posts.count {
            loadMorePosts()
         }
   }

   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let post = posts[indexPath.row]
      let comment = PFObject(className: "Comments")
      comment["text"] = "This is a random comment"
      comment["post"] = post
      comment["author"] = PFUser.current()

      post.add(comment, forKey: "comments")
      post.saveInBackground { (success, error) in
         if success{
            print("Comment saved")
         }else{
            print("Error saving comment")
         }
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

   @IBAction func onLogoutButton(_ sender: Any) {
      PFUser.logOut()

      let main = UIStoryboard(name: "Main", bundle: nil)
      let loginViewController = main.instantiateViewController(identifier: "LoginViewController")

      let delegate = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate

      delegate.window?.rootViewController = loginViewController
   }


}
