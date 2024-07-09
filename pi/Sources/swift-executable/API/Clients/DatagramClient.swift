import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif


final class DatagramClient {
    enum ClientError: Error {
        case noDataFound
    }

    private init() { }

    static func get() async throws -> Datagram {
        let url = URL(string: "http://10.0.50.21:3456/datagram")!
        let request = URLRequest(url: url)
        let data = try await URLSession.shared.asyncData(for: request)

        let decoder = JSONDecoder()
        let datagrams = try decoder.decode(DatagramsResponse.self, from: data.0)

        if let result = datagrams.datagrams.current {
            return result
        } else {
            throw ClientError.noDataFound
        }
    }
}