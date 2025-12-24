import XCTest
@testable import MusicPlaylistApp

final class YouTubeServiceTests: XCTestCase {
    var service: YouTubeService!
    
    override func setUpWithError() throws {
        service = YouTubeService.shared
    }
    
    override func tearDownWithError() throws {
        service = nil
    }
    
    func testValidateValidYouTubeURL() {
        let validURLs = [
            "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "https://youtube.com/watch?v=dQw4w9WgXcQ",
            "https://m.youtube.com/watch?v=dQw4w9WgXcQ",
            "https://youtu.be/dQw4w9WgXcQ"
        ]
        
        for url in validURLs {
            XCTAssertTrue(service.validateYouTubeURL(url), "URL should be valid: \(url)")
        }
    }
    
    func testValidateInvalidYouTubeURL() {
        let invalidURLs = [
            "https://www.google.com",
            "not a url",
            "https://vimeo.com/123456",
            ""
        ]
        
        for url in invalidURLs {
            XCTAssertFalse(service.validateYouTubeURL(url), "URL should be invalid: \(url)")
        }
    }
    
    func testExtractVideoIDFromStandardURL() {
        let url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
        let videoID = service.extractVideoID(from: url)
        
        XCTAssertEqual(videoID, "dQw4w9WgXcQ")
    }
    
    func testExtractVideoIDFromShortURL() {
        let url = "https://youtu.be/dQw4w9WgXcQ"
        let videoID = service.extractVideoID(from: url)
        
        XCTAssertEqual(videoID, "dQw4w9WgXcQ")
    }
    
    func testExtractVideoIDFromInvalidURL() {
        let url = "https://www.google.com"
        let videoID = service.extractVideoID(from: url)
        
        XCTAssertNil(videoID)
    }
}
