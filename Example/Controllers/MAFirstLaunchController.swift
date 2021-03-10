import UIKit
import MiniApp

class MAFirstLaunchController: UIViewController {

    @IBOutlet weak var miniAppMetaInfoContainer: UIView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var miniAppName: UILabel!
    @IBOutlet weak var miniAppVersion: UILabel!
    @IBOutlet weak var miniAppImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!

    weak var launchScreenDelegate: MALaunchScreenDelegate?
    var miniAppInfo: MiniAppInfo?
    var miniAppManifest: MiniAppManifest?
    var permissionsCollections: [MASDKCustomPermissionModel]?
    var alreadyAllowedPermissions: [MASDKCustomPermissionModel] = []
    var requiredPermissions: [MASDKCustomPermissionModel] = []
    var optionalPermissions: [MASDKCustomPermissionModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let podBundle: Bundle = Bundle.main
        let nib = UINib(nibName: "CustomPermissionCell", bundle: podBundle)
        self.tableView.register(nib, forCellReuseIdentifier: "FirstLaunchCustomPermissionCell")
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        alreadyAllowedPermissions = MiniApp.shared().getCustomPermissions(forMiniApp: miniAppInfo?.id ?? "").filter { $0.isPermissionGranted.boolValue == true }
        permissionsCollections = (miniAppManifest?.requiredPermissions ?? []) + (miniAppManifest?.optionalPermissions ?? [])
        permissionsCollections = removeAllowedPermissions(permsArray: permissionsCollections ?? [])
        requiredPermissions = removeAllowedPermissions(permsArray: miniAppManifest?.requiredPermissions ?? [])
        optionalPermissions = removeAllowedPermissions(permsArray: miniAppManifest?.optionalPermissions ?? [])
    }

    func removeAllowedPermissions(permsArray: [MASDKCustomPermissionModel]) -> [MASDKCustomPermissionModel] {
        return permsArray.filter {
            !alreadyAllowedPermissions.contains($0)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableViewHeightConstraint.constant = tableView.contentSize.height
    }

    func setupUI() {
        miniAppMetaInfoContainer.roundCorners(radius: 10)
        acceptButton.roundedCornerButton()
        self.tableView.layer.cornerRadius = 10.0
        closeButton.addBorderAndColor(color: #colorLiteral(red: 0.7472071648, green: 0, blue: 0, alpha: 1), width: 1, cornerRadius: 20, clipsToBounds: true)
        self.miniAppName.text = self.miniAppInfo?.displayName
        self.miniAppVersion.text = "Version: " + (self.miniAppInfo?.version.versionTag)!
        self.miniAppImageView.loadImage(self.miniAppInfo!.icon, placeholder: "image_placeholder", cache: nil)
    }

    @IBAction func acceptButtonPressed(_ sender: UIButton) {
        MiniApp.shared().setCustomPermissions(forMiniApp: miniAppInfo?.id ?? "", permissionList: permissionsCollections ?? [])
        _ = saveMiniAppLaunchInfo(isMiniAppLaunched: true, forKey: miniAppInfo!.id)
        launchScreenDelegate?.didUserResponded(agreed: true, miniAppInfo: miniAppInfo)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func closeButtonPressed(_ sender: UIButton) {
        launchScreenDelegate?.didUserResponded(agreed: false, miniAppInfo: miniAppInfo)
        self.dismiss(animated: true, completion: nil)
    }

    func isPermissionAllowedAlready(permissionModel: MASDKCustomPermissionModel?) -> Bool {
        guard let permission = permissionModel else {
            return false
        }
        return alreadyAllowedPermissions.contains(permission)
    }
}

// MARK: - UITableViewControllerDelegate
extension MAFirstLaunchController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return permissionsCollections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: "FirstLaunchCustomPermissionCell", for: indexPath) as? FirstLaunchCustomPermissionCell {
                let permissionModel: MASDKCustomPermissionModel?
                if requiredPermissions.indices.contains(indexPath.row) {
                    permissionModel =  requiredPermissions[indexPath.row]
                    if !isPermissionAllowedAlready(permissionModel: permissionModel) {
                        cell.permissionTitle?.attributedText =  NSMutableAttributedString()
                            .normalText(permissionModel?.permissionName.title ?? "")
                            .highlightRedColor(" (required)")
                        cell.permissionDescription?.text = permissionModel?.permissionDescription
                        cell.toggle.isHidden = true
                    } else {
                        return UITableViewCell()
                    }
                } else {
                    if optionalPermissions.indices.contains(indexPath.row - (requiredPermissions.count)) {
                            permissionModel =  optionalPermissions[indexPath.row - (requiredPermissions.count)]
                        if !isPermissionAllowedAlready(permissionModel: permissionModel) {
                            cell.permissionTitle?.text = permissionModel?.permissionName.title
                            cell.permissionDescription?.text = permissionModel?.permissionDescription
                        } else {
                            return UITableViewCell()
                        }
                    }
                }
            cell.toggle.tag = indexPath.row
            cell.toggle.isOn = true
            cell.toggle.addTarget(self, action: #selector(permissionValueChanged(_:)), for: .valueChanged)
            return cell
        }
        return UITableViewCell()
    }

    @objc func permissionValueChanged(_ sender: UISwitch) {
        if permissionsCollections?.indices.contains(sender.tag) ?? false {
            let permissionModel = permissionsCollections?[sender.tag]
            if sender.isOn {
                permissionModel?.isPermissionGranted = .allowed
            } else {
                permissionModel?.isPermissionGranted = .denied
            }
        }
    }
}

protocol MALaunchScreenDelegate: class {
    func didUserResponded(agreed: Bool, miniAppInfo: MiniAppInfo?)
}

class FirstLaunchCustomPermissionCell: UITableViewCell {

    @IBOutlet weak var permissionTitle: UILabel!
    @IBOutlet weak var permissionDescription: UILabel!
    @IBOutlet weak var toggle: UISwitch!

    override func prepareForReuse() {
        super.prepareForReuse()
        toggle.isOn = true
        permissionTitle.text = ""
        permissionDescription.text = ""
    }
}

extension NSMutableAttributedString {
    func highlightRedColor(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: #colorLiteral(red: 0.7472071648, green: 0, blue: 0, alpha: 1)
        ]
        self.append(NSAttributedString(string: value, attributes: attributes))
        return self
    }

    func normalText(_ value: String) -> NSMutableAttributedString {
        self.append(NSAttributedString(string: value, attributes: nil))
        return self
    }
}
