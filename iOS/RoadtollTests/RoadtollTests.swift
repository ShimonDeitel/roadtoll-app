import XCTest
@testable import Roadtoll

@MainActor
final class RoadtollTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
    }

    func testSeedDataBelowFreeLimit() {
        XCTAssertLessThan(store.entries.count, Store.freeLimit)
    }

    func testAddEntryIncreasesCount() {
        let before = store.entries.count
        store.add(Entry(origin: "Test", destination: "Test2", miles: 1, fuelCost: 2))
        XCTAssertEqual(store.entries.count, before + 1)
    }

    func testCanAddMoreWhenBelowLimit() {
        XCTAssertTrue(store.canAddMore)
    }

    func testCannotAddMoreAtLimit() {
        while store.entries.count < Store.freeLimit {
            store.add(Entry(origin: "X", destination: "Y", miles: 1, fuelCost: 1))
        }
        XCTAssertFalse(store.canAddMore)
    }

    func testDeleteEntryRemovesIt() {
        let entry = Entry(origin: "Del", destination: "Me", miles: 1, fuelCost: 1)
        store.add(entry)
        store.delete(entry)
        XCTAssertFalse(store.entries.contains(where: { $0.id == entry.id }))
    }

    func testUpdateEntryChangesFields() {
        var entry = Entry(origin: "Old", destination: "Old2", miles: 1, fuelCost: 1)
        store.add(entry)
        entry.origin = "New"
        store.update(entry)
        XCTAssertEqual(store.entries.first(where: { $0.id == entry.id })?.origin, "New")
    }

    func testDeleteAtOffsets() {
        store.add(Entry(origin: "A", destination: "B", miles: 1, fuelCost: 1))
        let before = store.entries.count
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.entries.count, before - 1)
    }
}
