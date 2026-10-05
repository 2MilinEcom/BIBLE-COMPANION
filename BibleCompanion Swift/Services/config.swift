import Foundation

enum APIConfig {
    #if targetEnvironment(simulator)
    static let baseURL = "http://127.0.0.1:8002"
    #else
    static let baseURL = "http://10.147.109.185:8002"
    #endif
}
