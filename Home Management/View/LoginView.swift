//
//  LoginView.swift
//  Home Management
//
//  Created by BaBaSaMa on 26/12/21.
//

import SwiftUI
import Alamofire
import SwiftyJSON
import AlertToast
import Drops

import CryptoKit
import Firebase
import FirebaseAuth
import AuthenticationServices
import GoogleSignIn

class LoginManager : ObservableObject {
    var viewController : UIViewController?
    
    func runLogin() {
        guard let viewController = viewController else {
            fatalError("No view controller")
        }
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: viewController) { user, error in
            if error != nil {
                debugPrint("user reject sigin with google, error: \(error)")
                return
            }
            
            guard let authentication = user?.authentication, let idToken = authentication.idToken else {
                debugPrint("auth failed, error: \(error)")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if (error != nil) {
                    print(error?.localizedDescription as Any)
                    return
                }
                guard let user = authResult?.user else { return }
                let uid = user.uid
                let displayName = user.displayName
                
                Task {
                    await login(uid, displayName ?? "")
                    
                    await viewController.dismiss(animated: true) {
                        print("dismissed")
                    }
                }
            }
        }
    }
}

struct DummyViewController : UIViewControllerRepresentable {
    var loginManager : LoginManager
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let vc = UIViewController()
        loginManager.viewController = vc
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

struct LoginView: View {
    @State var currentNonce: String?
    @State private var displayname: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isDarkMode: Bool = false
    @State private var newAccount: Bool = true
    @State private var guestLoginAlert: Bool = false
    @State private var loginManager = LoginManager()
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            Form {
                Section(content: {
                    VStack {
                        Toggle(isOn: $newAccount) {
                            Text("New Account?")
                        }
                        if newAccount {
                            TextField ("Display Name", text: $displayname)
                                .foregroundColor(isDarkMode ? Color.black : Color.white)
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .padding(.horizontal, 15)
                                .frame(width: maxWidth * 0.8, height: 40, alignment: .center)
                                .overlay(RoundedRectangle(cornerRadius: 7)
                                            .stroke(isDarkMode ? Color.white: Color.black, lineWidth: 2))
                                .padding(.vertical, 5)
                        }
                        
                        TextField ("Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding(.horizontal, 15)
                            .frame(width: maxWidth * 0.8, height: 40)
                            .overlay(RoundedRectangle(cornerRadius: 7)
                                        .stroke(isDarkMode ? Color.white: Color.black, lineWidth: 2))
                            .padding(.vertical, 5)
                        
                        TextField ("Password", text: $password)
                            .foregroundColor(Color.black)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .padding(.horizontal, 15)
                            .frame(width: maxWidth * 0.8, height: 40)
                            .overlay(RoundedRectangle(cornerRadius: 7)
                                        .stroke(isDarkMode ? Color.white: Color.black, lineWidth: 2))
                            .padding(.vertical, 5)
                        Button {
                            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                                guard let user = authResult?.user else { return }
                                let uid = user.uid
                                Task {
                                    if newAccount {
                                        await login(uid, displayname)
                                    } else {
                                        await login(uid, "")
                                    }
                                    
                                    await presentationMode.wrappedValue.dismiss()
                                }
                            }
                        } label: {
                            Text("Continue")
                                .foregroundColor(isDarkMode ? Color.black : Color.white)
                        }
                        .frame(width: maxWidth * 0.8, height: 40, alignment: .center)
                        .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                        .fill(isDarkMode ? Color.white : Color.black))
                        .padding(.vertical, 5)
                    }
                    .padding(.vertical, 5)
                }, header: {
                    Text("Sign in / Sign Up with Email")
                        .frame(alignment: .leading)
                })
                
                Section {
                    SignInWithAppleButton(
                        .continue,
                        onRequest: { request in
                            print("request")
                            let nonce = randomNonceString()
                            currentNonce = nonce
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = sha256(nonce)
                        },
                        onCompletion: { result in
                            print("complete")
                            switch result {
                            case .success(let authResults):
                                switch authResults.credential {
                                case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                    
                                    guard let nonce = currentNonce else {
                                        fatalError("Invalid state: A login callback was received, but no login request was sent.")
                                    }
                                    guard let appleIDToken = appleIDCredential.identityToken else {
                                        fatalError("Invalid state: A login callback was received, but no login request was sent.")
                                    }
                                    guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                                        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                                        return
                                    }
                                    
                                    let credential = OAuthProvider.credential(withProviderID: "apple.com",idToken: idTokenString,rawNonce: nonce)
                                    Auth.auth().signIn(with: credential) { (authResult, error) in
                                        if (error != nil) {
                                            print(error?.localizedDescription as Any)
                                            return
                                        }
                                        
                                        guard let user = authResult?.user else { return }
                                        let uid = user.uid
                                        let displayName = user.displayName
                                        
                                        Task {
                                            await login(uid, displayName ?? "")
                                            
                                            await presentationMode.wrappedValue.dismiss()
                                        }
                                    }
                                default:
                                    break
                                    
                                }
                            default:
                                break
                            }
                        }
                    )
                        .frame(width: maxWidth * 0.8, height: 40, alignment: .center)
                        .padding(.vertical, 5)
                    
                    Button {
                        loginManager.runLogin()
                    } label: {
                        HStack {
                            Image("google-icon")
                                .resizable()
                                .frame(width: 10, height: 10, alignment: .leading)
                            Text("Continue with Google")
                                .foregroundColor(Color.black)
                            
                            DummyViewController(loginManager: loginManager)
                                .frame(width: 0, height: 0)
                        }
                        .frame(alignment: .center)
                    }
                    .frame(width: maxWidth * 0.8, height: 40, alignment: .center)
                    .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                    .fill(Color.white))
                    .overlay(RoundedRectangle(cornerRadius: 7)
                                .stroke(isDarkMode ? Color.white: Color.black, lineWidth: 2))
                    .padding(.vertical, 5)
                    
                    Button {
                        guestLoginAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "person.fill")
                                .resizable()
                                .foregroundColor(Color.black)
                                .frame(width: 10, height: 10, alignment: .leading)
                            Text("Continue as Guest")
                                .foregroundColor(Color.black)
                            
                            DummyViewController(loginManager: loginManager)
                                .frame(width: 0, height: 0)
                        }
                        .frame(alignment: .center)
                    }
                    .frame(width: maxWidth * 0.8, height: 40, alignment: .center)
                    .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                                    .fill(isDarkMode ? Color.white : Color.gray))
                    .padding(.vertical, 5)
                } header: {
                    Text("Other Sign In / Sign Up Methods")
                        .frame(alignment: .leading)
                }
            }
            .frame(alignment: .center)
            .navigationTitle(Text("Login / Register"))
        }
        .onAppear {
            if colorScheme == .dark {
                isDarkMode = true
            }
        }
        .alert("Login as Guest", isPresented: $guestLoginAlert, actions: {
            Button("Cancel", role: .cancel) {}
            Button("Ok", role: nil) {
                Auth.auth().signInAnonymously { authResult, error in
                    guard let user = authResult?.user else { return }
                    let uid = user.uid
                    Task {
                        await login(uid, ("User " + String(Int.random(in: 1111..<9999))))
                        
                        await presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }, message: {
            Text("if you login as guest, you will not be able to use the full functionality. \nis that ok?")
        })
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
}

func login(_ uid: String, _ display_name: String) async {
    var login_parameter = JSON()
    login_parameter["user_id"].string = uid
    login_parameter["display_name"].string = display_name
    
    let defaults = UserDefaults.standard
    
    AF.request("https://api.babasama.com/home_management/auth/login", method: .get, parameters: login_parameter).response { response in
        switch response.result {
        case .success(let value):
            let json_response = JSON(value)
            if json_response["output"].stringValue == "success" {
                defaults.set("\(uid)", forKey: "user_id")
                defaults.set("\(display_name)", forKey: "display_name")
                return
            } else if json_response["output"].stringValue == "retry" {
                switch json_response["where_to"].stringValue {
                case "register":
                    Task {
                        await register(uid, display_name)
                    }
                    return
                default:
                    debugPrint(json_response)
                }
            } else {
                debugPrint(json_response)
            }
            
        case .failure(_):
            debugPrint(response)
        }
        
    }
}

func register(_ uid: String, _ display_name: String) async {
    
    let login_parameter = ["user_id": uid, "display_name": display_name]
    let defaults = UserDefaults.standard
    
    AF.request("https://api.babasama.com/home_management/auth/register", method: .post, parameters: login_parameter, encoder: JSONParameterEncoder.default, headers: HTTPHeaders.init(["Content-Type": "application/json"])).response { response in
        switch response.result {
        case .success(let value):
            let json_response = JSON(value)
            if json_response["output"].stringValue == "success" {
                defaults.set("\(uid)", forKey: "user_id")
                defaults.set("\(display_name)", forKey: "display_name")
                return
            } else if json_response["output"].stringValue == "retry" {
                switch json_response["where_to"].stringValue {
                case "login":
                    Task {
                        await login(uid, display_name)
                    }
                    
                default:
                    debugPrint(json_response)
                }
            } else {
                debugPrint(json_response)
            }
            
        case .failure(_):
            debugPrint(response)
        }
        
    }
}
