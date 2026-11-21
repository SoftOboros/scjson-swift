// Verify sparse SCJSON payloads and optional action order on the Codable surface.
// Part of the scjson project. Licensed under the BSD 1-Clause License.

import Foundation
import SCJSONKit
import XCTest

final class MixedPayloadTests: XCTestCase {
    func testMixedPayloadRoundTrip() throws {
        let source = Data(#"{"content":["  42 ",{"qname":"{urn:fixture}item"},{"version":1,"final":[{"id":"done"}]}]}"#.utf8)
        let value = try JSONDecoder().decode(ContentProps.self, from: source)
        let encoded = try JSONEncoder().encode(value)
        let input = try XCTUnwrap(JSONSerialization.jsonObject(with: source) as? NSDictionary)
        let output = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? NSDictionary)
        XCTAssertEqual(input["content"] as? NSArray, output["content"] as? NSArray)
    }

    func testAbsentAndExplicitOrderRoundTrip() throws {
        for source in ["{}", #"{"execution_order":[]}"#, #"{"execution_order":["send","assign"]}"#] {
            let input = Data(source.utf8)
            let value = try JSONDecoder().decode(OnentryProps.self, from: input)
            let encoded = try JSONEncoder().encode(value)
            let original = try XCTUnwrap(JSONSerialization.jsonObject(with: input) as? NSDictionary)
            let output = try XCTUnwrap(JSONSerialization.jsonObject(with: encoded) as? NSDictionary)
            XCTAssertEqual(original["execution_order"] as? NSArray, output["execution_order"] as? NSArray)
        }
    }

    func testParallelRegionOrderSurvivesSparseDecoding() throws {
        for source in ["{}", #"{"region_order":[]}"#,
                       #"{"state":[{}],"parallel":[{}],"region_order":["parallel","state"]}"#] {
            let input = Data(source.utf8)
            let value = try JSONDecoder().decode(ParallelProps.self, from: input)
            let output = try JSONSerialization.jsonObject(with: JSONEncoder().encode(value)) as? NSDictionary
            let original = try XCTUnwrap(JSONSerialization.jsonObject(with: input) as? NSDictionary)
            XCTAssertEqual(original["region_order"] as? NSArray, output?["region_order"] as? NSArray)
        }
    }
}
