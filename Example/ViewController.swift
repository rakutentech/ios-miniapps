import UIKit
import MiniApp

class ViewController: UITableViewController {

    var decodeResponse: [MiniAppInfo]?

    override func viewDidLoad() {
        super.viewDidLoad()
        showProgressIndicator()
        
        if let jsonData = "[{\"id\":\"c67f32b6-987d-405d-978f-6d8118b336ea\",\"displayName\":\"LookBook\",\"icon\":\"https://ysy.com\",\"version\":{\"versionTag\":\"1.0.0\",\"versionId\":\"9ab14a68-e8f9-4216-a6df-2c3b06f3c7f7\"}},{\"id\":\"34d0e875-e3aa-410b-b625-c71bc18a19c7\",\"displayName\":\"Panda Park\",\"icon\":\"https://ysy.com\",\"version\":{\"versionTag\":\"1.0.0\",\"versionId\":\"56dc97af-f278-465b-b985-ec383b6a4dac\"}},{\"id\":\"0d207c56-6cbf-44ba-b550-64266869b83f\",\"displayName\":\"Mixed Juice\",\"icon\":\"https://ysy.com\",\"version\":{\"versionTag\":\"1.0.0\",\"versionId\":\"b6dec279-9ad0-4da4-a46a-e4f4c3b18a01\"}}]".data(using: .utf8) {
            self.decodeResponse = try? JSONDecoder().decode([MiniAppInfo].self, from: jsonData)
            
        }

        MiniApp.list { (result) in
            switch result {
            case .success(let responseData):
                self.decodeResponse = responseData
                self.tableView.reloadData()
                self.dismissProgressIndicator()
            case .failure(let error):
                print(error.localizedDescription)
                self.displayErrorAlert(title: "Error", message: "Couldn't retrieve Mini App list, please try again later", dismissController: false)
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return decodeResponse?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MiniAppCell", for: indexPath)

        let miniAppDetail = self.decodeResponse?[indexPath.row]
        cell.textLabel?.text = miniAppDetail?.displayName
        cell.imageView?.image = UIImage(named: "image_placeholder")
        cell.imageView?.loadImageURL(url: miniAppDetail!.icon)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if segue.identifier == "DisplayMiniApp" {
        guard let indexPath = self.tableView.indexPathForSelectedRow?.row else {
            self.displayErrorAlert(title: "Error", message: "Couldn't retrieve Mini App, please try again later", dismissController: false)
            return
        }
        let displayController = segue.destination as? DisplayController
        displayController?.miniAppInfo = decodeResponse?[indexPath]
       }
    }
}

extension UIImageView {
    func loadImageURL(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
