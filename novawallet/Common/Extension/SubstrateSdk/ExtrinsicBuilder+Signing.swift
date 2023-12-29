import Foundation
import SubstrateSdk

enum ExtrinsicBuilderExtensionError: Error {
    case invalidRawSignature(data: Data)
}

extension ExtrinsicBuilderProtocol {
    func signing(
        with signingClosure: (Data, ExtrinsicSigningContext) throws -> Data,
        context: ExtrinsicSigningContext.Substrate,
        codingFactory: RuntimeCoderFactoryProtocol
    ) throws -> Self {
        switch context.chainFormat {
        case .ethereum:
            return try signing(
                by: { data in
                    let signature = try signingClosure(data, .substrateExtrinsic(context))

                    guard let ethereumSignature = EthereumSignature(rawValue: signature) else {
                        throw ExtrinsicBuilderExtensionError.invalidRawSignature(data: signature)
                    }

                    return try ethereumSignature.toScaleCompatibleJSON(
                        with: codingFactory.createRuntimeJsonContext().toRawContext()
                    )
                },
                using: codingFactory.createEncoder(),
                metadata: codingFactory.metadata
            )
        case .substrate:
            return try signing(
                by: { data in
                    try signingClosure(data, .substrateExtrinsic(context))
                },
                of: context.cryptoType.utilsType,
                using: codingFactory.createEncoder(),
                metadata: codingFactory.metadata
            )
        }
    }
}
