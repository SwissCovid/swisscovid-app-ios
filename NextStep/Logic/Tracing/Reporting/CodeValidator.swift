///

import Foundation

// 211 561 679
// 697 132 178

class CodeValidator {
    enum ValidationResult {
        case success(token: String, date: Date)
        case networkError
        case unexpectedError
        case invalidTokenError
    }

    func sendCodeRequest(code: String, completion: @escaping (ValidationResult) -> Void) {
        let auth = AuthorizationRequestBody(authorizationCode: code)

        let dataTask = URLSession.shared.dataTask(with: Endpoint.onset(auth: auth).request(), completionHandler: { data, response, error in

            DispatchQueue.main.async {
                if response == nil {
                    completion(.networkError)
                    return
                }

                if let response = response as? HTTPURLResponse {
                    if response.statusCode == 404 {
                        completion(.invalidTokenError)
                        return
                    } else if response.statusCode >= 300 {
                        completion(.unexpectedError)
                        return
                    }
                }

                if error != nil {
                    completion(.unexpectedError)
                    return
                }

                guard let d = data, let result = try? JSONDecoder().decode(AuthorizationResponseBody.self, from: d) else {
                    completion(.unexpectedError)
                    return
                }

                guard let jwtBody = result.accessToken.body else {
                    completion(.unexpectedError)
                    return
                }

                guard let dateString = jwtBody.keydate ?? jwtBody.onset else {
                    completion(.unexpectedError)
                    return
                }

                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                guard let date = formatter.date(from: dateString) else {
                    completion(.unexpectedError)
                    return
                }

                let token = result.accessToken

                completion(.success(token: token, date: date))
            }
        })

        dataTask.resume()
    }
}
