import Foundation

/// Form validation rule
public enum ValidationRule {
    case required
    case email
    case minLength(Int)
    case maxLength(Int)
    case regex(String, message: String)
    case custom((String) -> Bool, message: String)
    
    public var errorMessage: String {
        switch self {
        case .required:
            return DKLocalizer.string(for: .validationRequired)
        case .email:
            return DKLocalizer.string(for: .validationEmail)
        case .minLength(let length):
            return DKLocalizer.string(for: .validationMinLength, length)
        case .maxLength(let length):
            return DKLocalizer.string(for: .validationMaxLength, length)
        case .regex(_, let message):
            return message
        case .custom(_, let message):
            return message
        }
    }
}

/// Form field validation result
public enum ValidationResult {
    case valid
    case invalid(String)
    
    public var isValid: Bool {
        if case .valid = self {
            return true
        }
        return false
    }
    
    public var errorMessage: String? {
        if case .invalid(let message) = self {
            return message
        }
        return nil
    }
}

/// Form validator utility
public struct FormValidator {
    
    /// Validate a single field with multiple rules
    public static func validate(_ value: String, rules: [ValidationRule]) -> ValidationResult {
        for rule in rules {
            let result = validate(value, rule: rule)
            if !result.isValid {
                return result
            }
        }
        return .valid
    }
    
    /// Validate a single field with a single rule
    public static func validate(_ value: String, rule: ValidationRule) -> ValidationResult {
        switch rule {
        case .required:
            return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 
                .invalid(rule.errorMessage) : .valid
            
        case .email:
            let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            return predicate.evaluate(with: value) ? .valid : .invalid(rule.errorMessage)
            
        case .minLength(let length):
            return value.count >= length ? .valid : .invalid(rule.errorMessage)
            
        case .maxLength(let length):
            return value.count <= length ? .valid : .invalid(rule.errorMessage)
            
        case .regex(let pattern, _):
            let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
            return predicate.evaluate(with: value) ? .valid : .invalid(rule.errorMessage)
            
        case .custom(let validator, _):
            return validator(value) ? .valid : .invalid(rule.errorMessage)
        }
    }
}

/// Observable form field for validation
@available(iOS 14.0, macOS 11.0, *)
public class FormField: ObservableObject {
    @Published public var value: String
    @Published public var validationResult: ValidationResult = .valid
    
    public let rules: [ValidationRule]
    public let validateOnChange: Bool
    
    public init(
        initialValue: String = "",
        rules: [ValidationRule] = [],
        validateOnChange: Bool = false
    ) {
        self.value = initialValue
        self.rules = rules
        self.validateOnChange = validateOnChange
    }
    
    public func validate() -> ValidationResult {
        let result = FormValidator.validate(value, rules: rules)
        validationResult = result
        return result
    }
    
    public var isValid: Bool {
        validationResult.isValid
    }
    
    public var errorMessage: String? {
        validationResult.errorMessage
    }
}

/// Form container for managing multiple fields
@available(iOS 14.0, macOS 11.0, *)
public class Form: ObservableObject {
    @Published public var fields: [String: FormField]
    
    public init(fields: [String: FormField] = [:]) {
        self.fields = fields
    }
    
    public func addField(_ name: String, field: FormField) {
        fields[name] = field
    }
    
    public func validateAll() -> Bool {
        var isValid = true
        for (_, field) in fields {
            let result = field.validate()
            if !result.isValid {
                isValid = false
            }
        }
        return isValid
    }
    
    public func resetValidation() {
        for (_, field) in fields {
            field.validationResult = .valid
        }
    }
    
    public func resetAll() {
        for (_, field) in fields {
            field.value = ""
            field.validationResult = .valid
        }
    }
}

// MARK: - Common Validation Patterns

extension ValidationRule {
    /// Phone number validation (E.164-style: digits only, 7–15 chars)
    public static var phone: ValidationRule {
        .regex("^[+]?[0-9]{7,15}$", message: DKLocalizer.string(for: .validationPhone))
    }

    /// Legacy alias kept for backwards compatibility with apps that used `.turkishPhone`.
    @available(*, deprecated, renamed: "phone")
    public static var turkishPhone: ValidationRule { .phone }

    /// Strong password validation
    public static var strongPassword: ValidationRule {
        .regex(
            "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$",
            message: DKLocalizer.string(for: .validationPasswordStrength)
        )
    }

    /// URL validation
    public static var url: ValidationRule {
        .regex("^https?://[\\w.-]+\\.[a-zA-Z]{2,}.*$", message: DKLocalizer.string(for: .validationURL))
    }

    /// Alphanumeric validation
    public static var alphanumeric: ValidationRule {
        .regex("^[a-zA-Z0-9]+$", message: DKLocalizer.string(for: .validationAlphanumeric))
    }
}

