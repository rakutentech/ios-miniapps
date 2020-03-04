import UIKit
import MiniApp

class ViewController: UITableViewController {

    var decodeResponse: [MiniAppInfo]?
    var currentMiniAppInfo: MiniAppInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
        showProgressIndicator()

        MiniApp.list { (result) in
            switch result {
            case .success(let responseData):
                self.decodeResponse = responseData
                self.tableView.reloadData()
                self.dismissProgressIndicator()
            case .failure(let error):
                print(error.localizedDescription)
                self.displayErrorAlert(title: NSLocalizedString("error_title", comment: ""), message: NSLocalizedString("error_list_message", comment: ""), dismissController: false)
            }
        }
    }

    @IBAction func actionShowMiniAppById() {
        self.displayTextFieldAlert(title: NSLocalizedString("input_miniapp_title", comment: "")) { (_, textField) in
            self.dismiss(animated: true) {
                if let textField = textField, let miniAppID = textField.text, miniAppID.count > 0 {
                    self.showProgressIndicator {
                        MiniApp.info(miniAppId: miniAppID) { (result) in
                            self.dismissProgressIndicator {
                                switch result {
                                case .success(let responseData):
                                    self.currentMiniAppInfo = responseData
                                    self.performSegue(withIdentifier: "DisplayMiniApp", sender: nil)
                                case .failure(let error):
                                    print(error.localizedDescription)
                                    self.displayErrorAlert(
                                        title: NSLocalizedString("error_title", comment: ""),
                                        message: NSLocalizedString("error_single_message", comment: ""),
                                        dismissController: false)
                                }
                            }
                        }
                    }
                } else {
                    self.displayErrorAlert(
                        title: NSLocalizedString("error_title", comment: ""),
                        message: NSLocalizedString("error_incorrect_appid_message", comment: ""),
                        dismissController: false)
                }
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
            if let indexPath = self.tableView.indexPathForSelectedRow?.row {
                currentMiniAppInfo = decodeResponse?[indexPath]
            }

            guard let miniAppInfo = self.currentMiniAppInfo else {
                self.displayErrorAlert(title: NSLocalizedString("error_title", comment: ""), message: NSLocalizedString("error_miniapp_message", comment: ""), dismissController: false)
                return
            }

            let displayController = segue.destination as? DisplayController
            displayController?.miniAppInfo = miniAppInfo
            self.currentMiniAppInfo = nil
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
