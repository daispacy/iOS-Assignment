//
//  User.swift
//  iOS Assignment
//
//  Created by Dai on 15/09/2020.
//  Copyright © 2020 Dai. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: - UsersResponse
public class UsersResponse: Codable {
    let results: [User]?
    let info: Info?

    init(results: [User]?, info: Info?) {
        self.results = results
        self.info = info
    }
}

// MARK: UsersResponse convenience initializers and mutators

extension UsersResponse {
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(UsersResponse.self, from: data)
        self.init(results: me.results, info: me.info)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        results: [User]?? = nil,
        info: Info?? = nil
    ) -> UsersResponse {
        return UsersResponse(
            results: results ?? self.results,
            info: info ?? self.info
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - Info
class Info: Codable {
    let seed: String?
    let results, page: Int?
    let version: String?

    init(seed: String?, results: Int?, page: Int?, version: String?) {
        self.seed = seed
        self.results = results
        self.page = page
        self.version = version
    }
}

// MARK: - Result
public class User: Codable {
    let gender: String?
    let name: Name?
    let location: Location?
    let email: String?
    let login: Login?
    let dob, registered: Dob?
    let phone, cell: String?
    let id: ID?
    let picture: Picture?
    let nat: String?
    
    var isMale:Bool {
        get {
            return gender == "male"
        }
    }

    init(gender: String?, name: Name?, location: Location?, email: String?, login: Login?, dob: Dob?, registered: Dob?, phone: String?, cell: String?, id: ID?, picture: Picture?, nat: String?) {
        self.gender = gender
        self.name = name
        self.location = location
        self.email = email
        self.login = login
        self.dob = dob
        self.registered = registered
        self.phone = phone
        self.cell = cell
        self.id = id
        self.picture = picture
        self.nat = nat
    }
    
    convenience init(data: Data) throws {
        let me = try newJSONDecoder().decode(User.self, from: data)
        self.init(gender: me.gender, name: me.name, location: me.location, email: me.email, login: me.login, dob: me.dob, registered: me.registered, phone: me.phone, cell: me.cell, id: me.id, picture: me.picture, nat: me.nat)
    }

    convenience init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    convenience init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        gender: String?? = nil,
        name: Name?? = nil,
        location: Location?? = nil,
        email: String?? = nil,
        login: Login?? = nil,
        dob: Dob?? = nil,
        registered: Dob?? = nil,
        phone: String?? = nil,
        cell: String?? = nil,
        id: ID?? = nil,
        picture: Picture?? = nil,
        nat: String?? = nil
    ) -> User {
        return User(
            gender: gender ?? self.gender,
            name: name ?? self.name,
            location: location ?? self.location,
            email: email ?? self.email,
            login: login ?? self.login,
            dob: dob ?? self.dob,
            registered: registered ?? self.registered,
            phone: phone ?? self.phone,
            cell: cell ?? self.cell,
            id: id ?? self.id,
            picture: picture ?? self.picture,
            nat: nat ?? self.nat
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
    
    func getFullName() -> String {
        var fullname = ""
        if let title = name?.title {
            fullname += title + " "
        }
        if let fName = name?.first {
            fullname += fName + " "
        }
        if let lName = name?.last {
            fullname += lName
        }
        return fullname
    }
    
    func getFullAddress() -> String {
        var address = ""
        if let number = location?.street?.number {
            address += "\(number)" + " "
        }
        
        if let name = location?.street?.name {
            address += name + ", "
        }
        
        if let city = location?.city {
            address += city + ", "
        }
        
        if let state = location?.state {
            address += state + " "
        }
        
        if let postCode = location?.postcode?.value as? String {
            address += postCode + ", "
        } else if let postCode = location?.postcode?.value as? Int {
            address += "\(postCode)" + ", "
        }
        
        if let country = location?.country {
            address += country + " "
        }
        
        return address
    }
}

// MARK: - Dob
public class Dob: Codable {
    let date: String?
    let age: Int?

    init(date: String?, age: Int?) {
        self.date = date
        self.age = age
    }
}

// MARK: - ID
public class ID: Codable {
    let name, value: String?

    init(name: String?, value: String?) {
        self.name = name
        self.value = value
    }
}

// MARK: - Location
public class Location: Codable {
    let street: Street?
    let city, state, country: String?
    let postcode: AnyCodable?
    let coordinates: Coordinates?
    let timezone: Timezone?

    init(street: Street?, city: String?, state: String?, country: String?, postcode: AnyCodable?, coordinates: Coordinates?, timezone: Timezone?) {
        self.street = street
        self.city = city
        self.state = state
        self.country = country
        self.postcode = postcode
        self.coordinates = coordinates
        self.timezone = timezone
    }
    
    required public init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        street = try values.decodeIfPresent(Street.self, forKey: .street) ?? nil
        city = try values.decodeIfPresent(String.self, forKey: .city) ?? nil
        state = try values.decodeIfPresent(String.self, forKey: .state) ?? nil
        country = try values.decodeIfPresent(String.self, forKey: .country) ?? nil
        postcode = try values.decodeIfPresent(AnyCodable.self, forKey: .postcode)
        coordinates = try values.decodeIfPresent(Coordinates.self, forKey: .coordinates) ?? nil
        timezone = try values.decodeIfPresent(Timezone.self, forKey: .timezone) ?? nil
    }
    
    func getCoordinates() -> CLLocationCoordinate2D? {
        
        if let latString = coordinates?.latitude,
           let longString = coordinates?.longitude,
           let lat = Double(latString),
           let long = Double(longString) {
            return CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        return nil
    }
}

// MARK: - Coordinates
public class Coordinates: Codable {
    let latitude, longitude: String?

    init(latitude: String?, longitude: String?) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - Street
public class Street: Codable {
    let number: Int?
    let name: String?

    init(number: Int?, name: String?) {
        self.number = number
        self.name = name
    }
}

// MARK: - Timezone
public class Timezone: Codable {
    let offset, timezoneDescription: String?

    enum CodingKeys: String, CodingKey {
        case offset
        case timezoneDescription = "description"
    }

    init(offset: String?, timezoneDescription: String?) {
        self.offset = offset
        self.timezoneDescription = timezoneDescription
    }
}

// MARK: - Login
public class Login: Codable {
    let uuid, username, password, salt: String?
    let md5, sha1, sha256: String?

    init(uuid: String?, username: String?, password: String?, salt: String?, md5: String?, sha1: String?, sha256: String?) {
        self.uuid = uuid
        self.username = username
        self.password = password
        self.salt = salt
        self.md5 = md5
        self.sha1 = sha1
        self.sha256 = sha256
    }
}

// MARK: - Name
public class Name: Codable {
    let title, first, last: String?

    init(title: String?, first: String?, last: String?) {
        self.title = title
        self.first = first
        self.last = last
    }
}

// MARK: - Picture
public class Picture: Codable {
    let large, medium, thumbnail: String?

    init(large: String?, medium: String?, thumbnail: String?) {
        self.large = large
        self.medium = medium
        self.thumbnail = thumbnail
    }
}

// MARK: -  Any
public struct AnyCodable: Decodable {
    public var value: Any
    
    public struct CodingKeys: CodingKey {
        public var stringValue: String
        public var intValue: Int?
        public init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
        public init?(stringValue: String) { self.stringValue = stringValue }
    }
    
    public init(value: Any) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            var result = [String: Any]()
            try container.allKeys.forEach { (key) throws in
                result[key.stringValue] = try container.decode(AnyCodable.self, forKey: key).value
            }
            value = result
        } else if var container = try? decoder.unkeyedContainer() {
            var result = [Any]()
            while !container.isAtEnd {
                result.append(try container.decode(AnyCodable.self).value)
            }
            value = result
        } else if let container = try? decoder.singleValueContainer() {
            if let intVal = try? container.decode(Int.self) {
                value = intVal
            } else if let doubleVal = try? container.decode(Double.self) {
                value = doubleVal
            } else if let boolVal = try? container.decode(Bool.self) {
                value = boolVal
            } else if let stringVal = try? container.decode(String.self) {
                value = stringVal
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "the container contains nothing serialisable")
            }
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not serialise"))
        }
    }
}

extension AnyCodable: Encodable {
    public func encode(to encoder: Encoder) throws {
        if let array = value as? [Any] {
            var container = encoder.unkeyedContainer()
            for value in array {
                let decodable = AnyCodable(value: value)
                try container.encode(decodable)
            }
        } else if let dictionary = value as? [String: Any] {
            var container = encoder.container(keyedBy: CodingKeys.self)
            for (key, value) in dictionary {
                let codingKey = CodingKeys(stringValue: key)!
                let decodable = AnyCodable(value: value)
                try container.encode(decodable, forKey: codingKey)
            }
        } else {
            var container = encoder.singleValueContainer()
            if let intVal = value as? Int {
                try container.encode(intVal)
            } else if let doubleVal = value as? Double {
                try container.encode(doubleVal)
            } else if let boolVal = value as? Bool {
                try container.encode(boolVal)
            } else if let stringVal = value as? String {
                try container.encode(stringVal)
            } else {
                throw EncodingError.invalidValue(value, EncodingError.Context.init(codingPath: [], debugDescription: "The value is not encodable"))
            }
            
        }
    }
}
