//
//  Double+roundTo.swift
//  Snacktacular


import Foundation


//Rounding Function for Doubles

extension Double {
    
    func roundTo(places: Int) -> Double{
        let tenToPower = pow(10.0, Double(places >= 0 ? places : 0 ))
        let roundedValue = (self * tenToPower).rounded() / tenToPower
        return roundedValue
    }
    
}
