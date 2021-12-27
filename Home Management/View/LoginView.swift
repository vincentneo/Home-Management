//
//  LoginView.swift
//  Home Management
//
//  Created by BaBaSaMa on 26/12/21.
//

import SwiftUI
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
            guard error == nil else { return }
            guard let user = user else { return }

            if let profiledata = user.profile {
                let userID: String = user.userID ?? ""
                print(userID)
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
    @State var currentNonce:String?
    @StateObject private var loginManager = LoginManager()
    
    var body: some View {
        VStack {
            SignInWithAppleButton(
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
                                print("signed in")
                            }
                            
                            print("\(String(describing: Auth.auth().currentUser?.uid))")
                        default:
                            break
                            
                        }
                    default:
                        break
                    }
                }
            )
                .frame(width: maxWidth * 0.8, height: 40, alignment: .bottom)
                .padding(.bottom, 20)
            
            Button {
                loginManager.runLogin()
            } label: {
                HStack {
                    Image("google-icon")
                        .resizable()
                        .frame(width: 10, height: 10, alignment: .leading)
                    Text("Sign in with Google")
                        .foregroundColor(Color.black)
                    
                    DummyViewController(loginManager: loginManager)
                        .frame(width: 0, height: 0)
                }
                .frame(alignment: .center)
            }
            .frame(width: maxWidth * 0.8, height: 40, alignment: .center)
            .background(RoundedCorners(tl: 5, tr: 5, bl: 5, br: 5)
                            .fill(Color.gray))
        }
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
