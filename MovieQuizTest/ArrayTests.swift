//
//  ArrayTests.swift
//  MovieQuiz
//
//  Created by Konstantin on 12.07.2026.
//

import Foundation
import XCTest 
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
       // Given
        let array = [1,1,2,3,5]
        
        let value = array[safe: 2]
        // When 
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
        // Then 
    }
    
    func testGetValueOutOfRange() throws {
        // Given
        let array = [1, 1, 2, 3, 5]
            
        // When
        let value = array[safe: 20]
            
        // Then
        XCTAssertNil(value)
    }
}
