import Foundation


// =========================================================
// MARK: - AI Response
// =========================================================

struct AIResponse: Codable {

    let answer: String

    let responseID: String


    enum CodingKeys: String, CodingKey {

        case answer

        case responseID = "response_id"
    }
}


// =========================================================
// MARK: - AI Request
// =========================================================

struct AIRequest: Codable {

    let question: String

    let passage: String

    let mode: String

    let previousResponseID: String?

    let profile: SpiritualProfile


    /// Structured personalization context built locally by
    /// PersonalizationContextService.
    ///
    /// Kept separate from `question` so the backend can
    /// distinguish:
    ///
    /// - the user's current message
    /// - saved profile information
    /// - observed study history
    /// - user-written reflections
    /// - AI-generated summaries
    ///
    /// Optional for backwards compatibility with any screens
    /// that have not been migrated yet.
    let personalizationContext: PersonalizationContext?


    enum CodingKeys: String, CodingKey {

        case question

        case passage

        case mode

        case profile

        case previousResponseID = "previous_response_id"

        case personalizationContext = "personalization_context"
    }
}


// =========================================================
// MARK: - AI Service
// =========================================================

final class AIService {

    // =====================================================
    // MARK: Singleton
    // =====================================================

    static let shared = AIService()


    // =====================================================
    // MARK: Init
    // =====================================================

    private init() {}


    // =====================================================
    // MARK: - Ask
    // =====================================================

    func ask(
        question: String,
        passage: String,
        mode: StudyMode,
        previousResponseID: String?,
        profile: SpiritualProfile,
        personalizationContext: PersonalizationContext? = nil
    ) async throws -> AIResponse {

        guard
            let url = URL(
                string: "\(APIConfig.baseURL)/ask"
            )
        else {

            print("❌ INVALID URL")
            print("❌ APIConfig.baseURL:", APIConfig.baseURL)

            throw URLError(
                .badURL
            )
        }


        var request =
            URLRequest(
                url: url
            )


        request.httpMethod =
            "POST"


        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Content-Type"
        )


        request.setValue(
            "application/json",
            forHTTPHeaderField:
                "Accept"
        )


        // -------------------------------------------------
        // Request Body
        // -------------------------------------------------

        let body =
            AIRequest(

                question:
                    question,

                passage:
                    passage,

                mode:
                    mode.rawValue,

                previousResponseID:
                    previousResponseID,

                profile:
                    profile,

                personalizationContext:
                    personalizationContext
            )


        let encoder =
            JSONEncoder()


        // PersonalizationContext contains dates from journey
        // history. ISO-8601 keeps those values readable and
        // predictable for the Flask backend.
        encoder.dateEncodingStrategy =
            .iso8601


        request.httpBody =
            try encoder
                .encode(
                    body
                )


        // -------------------------------------------------
        // Network Request
        // -------------------------------------------------

        print("")
        print("==========================================")
        print("🚨 ABOUT TO SEND NETWORK REQUEST")
        print("==========================================")
        print("🚨 REQUEST URL:", request.url?.absoluteString ?? "nil")
        print("🚨 API BASE URL:", APIConfig.baseURL)
        print("🚨 HTTP METHOD:", request.httpMethod ?? "nil")
        print("🚨 DEVICE REQUEST STARTING")
        print("==========================================")
        print("")


        let data: Data
        let response: URLResponse

        do {

            let result =
                try await URLSession
                    .shared
                    .data(
                        for:
                            request
                    )

            data = result.0
            response = result.1


            print("")
            print("==========================================")
            print("✅ NETWORK REQUEST COMPLETED")
            print("==========================================")

            if let httpResponse =
                response as? HTTPURLResponse {

                print(
                    "✅ STATUS CODE:",
                    httpResponse.statusCode
                )
            }

            print(
                "✅ RECEIVED BYTES:",
                data.count
            )

            print("==========================================")
            print("")

        } catch {

            print("")
            print("==========================================")
            print("❌ NETWORK REQUEST FAILED")
            print("==========================================")
            print("❌ ERROR:", error)
            print(
                "❌ DESCRIPTION:",
                error.localizedDescription
            )

            if let urlError =
                error as? URLError {

                print(
                    "❌ URL ERROR CODE:",
                    urlError.code.rawValue
                )

                print(
                    "❌ URL ERROR:",
                    urlError.code
                )
            }

            print(
                "❌ ATTEMPTED URL:",
                request.url?.absoluteString ?? "nil"
            )

            print("==========================================")
            print("")

            throw error
        }


        guard
            let httpResponse =
                response
                    as?
                    HTTPURLResponse
        else {

            throw URLError(
                .badServerResponse
            )
        }


        // -------------------------------------------------
        // Server Error
        // -------------------------------------------------

        guard
            200..<300
                ~= httpResponse
                    .statusCode
        else {

            let serverMessage =
                extractServerError(
                    from:
                        data
                )
                ??
                "Unknown server error"


            print("")
            print("==========================================")
            print("❌ SERVER RETURNED AN ERROR")
            print("==========================================")
            print(
                "❌ STATUS CODE:",
                httpResponse.statusCode
            )
            print(
                "❌ SERVER MESSAGE:",
                serverMessage
            )
            print("==========================================")
            print("")


            throw NSError(

                domain:
                    "AIService",

                code:
                    httpResponse
                        .statusCode,

                userInfo: [

                    NSLocalizedDescriptionKey:
                        serverMessage
                ]
            )
        }


        // -------------------------------------------------
        // Decode Response
        // -------------------------------------------------

        do {

            let decodedResponse =
                try JSONDecoder()
                    .decode(
                        AIResponse.self,
                        from:
                            data
                    )

            print("")
            print("==========================================")
            print("✅ RESPONSE DECODED SUCCESSFULLY")
            print("==========================================")
            print("")

            return decodedResponse

        } catch {

            print("")
            print("==========================================")
            print("❌ RESPONSE DECODING FAILED")
            print("==========================================")
            print(
                "❌ ERROR:",
                error.localizedDescription
            )

            if let rawResponse =
                String(
                    data:
                        data,
                    encoding:
                        .utf8
                ) {

                print(
                    "❌ RAW RESPONSE:",
                    rawResponse
                )
            }

            print("==========================================")
            print("")

            throw error
        }
    }


    // =====================================================
    // MARK: - Server Error Helper
    // =====================================================

    private func extractServerError(
        from data:
            Data
    ) -> String? {

        // Flask usually returns:
        //
        // {
        //   "error": "..."
        // }

        if
            let object =
                try?
                JSONSerialization
                    .jsonObject(
                        with:
                            data
                    )
                as?
                [String: Any],

            let message =
                object["error"]
                as?
                String {

            let cleaned =
                message
                    .trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )


            if !cleaned.isEmpty {

                return cleaned
            }
        }


        // Fall back to the raw server body.

        if
            let raw =
                String(
                    data:
                        data,
                    encoding:
                        .utf8
                ) {

            let cleaned =
                raw
                    .trimmingCharacters(
                        in:
                            .whitespacesAndNewlines
                    )


            if !cleaned.isEmpty {

                return cleaned
            }
        }


        return nil
    }
}
