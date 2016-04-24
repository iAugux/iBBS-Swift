import Alamofire
import SwiftyJSON

extension Request {
    public static func SwiftyJSONResponseSerializer(
        options options: NSJSONReadingOptions = .AllowFragments)
        -> ResponseSerializer<JSON, NSError>
    {
        return ResponseSerializer { _, _, data, error in
            guard error == nil else { return .Failure(error!) }
            
            guard let validData = data where validData.length > 0 else {
                let failureReason = "JSON could not be serialized. Input data was nil or zero length."
                let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            let json:JSON = SwiftyJSON.JSON(data: validData)
            if let jsonError = json.error {
                return Result.Failure(jsonError)
            }
            
            return Result.Success(json)
        }
    }
    
    public func responseSwiftyJSON(
        options options: NSJSONReadingOptions = .AllowFragments,
                completionHandler: Response<JSON, NSError> -> Void)
        -> Self
    {
        return response(
            responseSerializer: Request.SwiftyJSONResponseSerializer(options: options),
            completionHandler: completionHandler
        )
    }
}
