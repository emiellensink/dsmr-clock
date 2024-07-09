struct DatagramsResponse: Decodable {
    let datagrams: Datagrams
}

struct Datagrams: Decodable {
    let current: Datagram?
    let previous: Datagram?
}

struct Datagram: Decodable {
    let electricity: Electricity
}

struct Electricity: Decodable {
    let received: ElectricityUnit
    let delivered: ElectricityUnit
}

struct ElectricityUnit: Decodable {
    let tariff1: ElectricityReading?
    let tariff2: ElectricityReading?
    let actual: ElectricityReading

    var total: ElectricityReading {
        let total = (tariff1?.reading ?? 0) + (tariff2?.reading ?? 0)
        let unit = tariff1?.unit ?? tariff2?.unit ?? ""

        return ElectricityReading(reading: total, unit: unit)
    }
}

struct ElectricityReading: Decodable {
    let reading: Double
    let unit: String
}
