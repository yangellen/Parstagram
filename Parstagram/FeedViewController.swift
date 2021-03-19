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

      let query = PFQuery(className: "Post")
      query.order(byDescending: "createdAt")
      query.includeKey("author")
      query.limit = 20

      query.findObjectsInBackground { (posts, error) in
         if posts != nil{
            self.posts = posts!
            self.tableView.reloadData()
         }
      }

   }

   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

      return posts.count
   }

   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell

      let post = posts[indexPath.row]
      let user = post["author"] as! PFUser
      cell.usernameLabel.text = user.username
      cell.captionLabel.text = post["caption"] as? String

      let imageFile = post["image"] as! PFFileObject
      let urlString = imageFile.url!
      let url = URL(string: urlString)!

      cell.photoView.af.setImage(withURL: url)


      return cell 
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
