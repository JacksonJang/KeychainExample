import UIKit
import Security

class ViewController: UIViewController {
    private let accountTextField: UITextField = {
        let textField = UITextField()
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter an account"
        
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter a password"
        
        return textField
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("ADD", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        
        return button
    }()
    
    private let getButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("GET", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        
        return button
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "result"
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupUI()
    }

    private func setupUI() {
        self.view.backgroundColor = .white
        
        [
            accountTextField,
            passwordTextField,
            addButton,
            getButton,
            resultLabel
        ].forEach {
            self.view.addSubview($0)
        }
        
        setupConstraints()
        setupBindings()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            accountTextField.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            accountTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            accountTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
            accountTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            passwordTextField.topAnchor.constraint(equalTo: self.accountTextField.bottomAnchor, constant: 20),
            passwordTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            passwordTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: self.passwordTextField.bottomAnchor, constant: 20),
            addButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            addButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            getButton.topAnchor.constraint(equalTo: self.addButton.bottomAnchor, constant: 20),
            getButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            getButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
            getButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            resultLabel.topAnchor.constraint(equalTo: self.getButton.bottomAnchor, constant: 20),
            resultLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 20),
            resultLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -20),
        ])
    }
    
    private func setupBindings() {
        addButton.addTarget(self, action: #selector(addToKeychain), for: .touchUpInside)
        getButton.addTarget(self, action: #selector(getFromKeychain), for: .touchUpInside)
    }
}

// MARK: - Keychain
extension ViewController {
    @objc func addToKeychain() {
        guard let accountText = self.accountTextField.text,
              let passwordText = self.passwordTextField.text 
        else {
            return
        }
        let account = accountText.data(using: .utf8)!
        let password = passwordText.data(using: .utf8)!
        
        // 저장할 데이터 설정
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecValueData as String: password
        ]

        // 이전 데이터 삭제
        SecItemDelete(query as CFDictionary)

        // 데이터 저장
        let status = SecItemAdd(query as CFDictionary, nil)
        
        // 데이터 저장 에러 여부
        if status != errSecSuccess {
            if let errorMessage = SecCopyErrorMessageString(status, nil) {
                print("키체인 저장 실패 : \(errorMessage)")
            }
        }
    }
    
    @objc func getFromKeychain(){
        guard let accountText = self.accountTextField.text else {
            return
        }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: accountText.data(using: .utf8)!,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: true
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess, 
        let data = item as? Data,
        let password = String(data: data, encoding: .utf8) {
            self.resultLabel.text = password
        } else {
            if let errorMessage = SecCopyErrorMessageString(status, nil) {
                print("키체인 조회 시: \(errorMessage)")
            }
            self.resultLabel.text = ""
        }
    }
}

