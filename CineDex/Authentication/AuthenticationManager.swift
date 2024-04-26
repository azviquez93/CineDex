//
//  AuthenticationManager.swift
//  CineDex
//
//  Created by Andrés Zamora on 8/3/24.
//

import Alamofire
import Foundation

struct AuthDataResultModel: Decodable {
  let token: String
}

final class AuthenticationManager {
  
  static let shared = AuthenticationManager()
  private init() {}
  
  //  @discardableResult
  //  func createUser(email: String, password: String) async throws -> AuthDataResultModel {
  //    //let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
  //  }
  
  func getAuthenticatedUser() -> AuthDataResultModel? {
    guard let token = UserDefaults.standard.object(forKey: "userToken") as? String else {
      return nil
    }
    return AuthDataResultModel(token: token)
  }
  
  func register(email: String, password: String) async throws -> AuthDataResultModel {
    let url = URL(string: "http://192.168.68.100:8000/api/v1/auth/register")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let parameters: [String: Any] = ["name": "Name", "email": email, "password": password]
    request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
    
    let (data, _) = try await URLSession.shared.data(for: request)
    let decoder = JSONDecoder()
    let authDataResultModel = try decoder.decode(AuthDataResultModel.self, from: data)
    UserDefaults.standard.set(authDataResultModel.token, forKey: "userToken")
    
    return authDataResultModel
  }
  
  func signIn(email: String, password: String) async throws -> AuthDataResultModel {
    let url = URL(string: "http://192.168.68.100:8000/api/v1/auth/login")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let parameters: [String: Any] = ["email": email, "password": password]
    request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
    
    let (data, _) = try await URLSession.shared.data(for: request)
    let decoder = JSONDecoder()
    let authDataResultModel = try decoder.decode(AuthDataResultModel.self, from: data)
    UserDefaults.standard.set(authDataResultModel.token, forKey: "userToken")
    
    return authDataResultModel
  }
  
  func signOut() async throws {
    guard let url = URL(string: "http://192.168.68.100:8000/api/v1/auth/logout") else {
      throw NSError(domain: "Invalid URL", code: -1, userInfo: nil)
    }
    
    if let token = UserDefaults.standard.string(forKey: "userToken") {
      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
      
      let (_, response) = try await URLSession.shared.data(for: request)
      
      if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
        print("Logout successful")
        print(token )
        // Clear user-specific data
        UserDefaults.standard.removeObject(forKey: "userToken")
      } else {
        print("Logout failed")
        // Handle the error, e.g., show an alert
      }
    } else {
      print("No token found for logout")
    }
  }
  
}
