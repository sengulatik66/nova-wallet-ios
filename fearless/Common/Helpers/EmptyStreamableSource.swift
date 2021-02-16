import Foundation
import RobinHood

final class EmptyStreamableSource: StreamableSourceProtocol {
    typealias Model = RuntimeMetadataItem

    func fetchHistory(runningIn queue: DispatchQueue?,
                      commitNotificationBlock: ((Result<Int, Error>?) -> Void)?) {
        guard let closure = commitNotificationBlock else {
            return
        }

        let result: Result<Int, Error> = Result.success(0)

        if let queue = queue {
            queue.async {
                closure(result)
            }
        } else {
            closure(result)
        }
    }

    func refresh(runningIn queue: DispatchQueue?,
                 commitNotificationBlock: ((Result<Int, Error>?) -> Void)?) {
        guard let closure = commitNotificationBlock else {
            return
        }

        let result: Result<Int, Error> = Result.success(0)

        if let queue = queue {
            queue.async {
                closure(result)
            }
        } else {
            closure(result)
        }
    }
}
