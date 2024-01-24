import Foundation
import SubstrateSdk
import BigInt

enum XcmDeliveryFee: Decodable {
    struct FeeType: Decodable {
        let type: String
    }

    struct Exponential: Decodable {
        let factorPallet: String
        @StringCodable var sizeBase: BigUInt
        @StringCodable var sizeFactor: BigUInt
        let alwaysHoldingPays: Bool?

        var isSenderPaysOriginDelivery: Bool {
            !(alwaysHoldingPays ?? false)
        }

        var factorStoragePath: StorageCodingPath {
            StorageCodingPath(moduleName: factorPallet, itemName: "DeliveryFeeFactor")
        }
    }

    case exponential(Exponential)
    case undefined

    init(from decoder: Decoder) throws {
        let feeType = try FeeType(from: decoder).type

        switch feeType {
        case "exponential":
            let value = try Exponential(from: decoder)
            self = .exponential(value)
        default:
            self = .undefined
        }
    }
}
