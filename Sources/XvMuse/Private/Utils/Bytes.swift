//
//  Bytes.swift
//  XvUtils
//
//  Created by Jason Snell on 6/21/20.
//  Copyright © 2020 Jason J. Snell. All rights reserved.
//

import Foundation

public class Bytes {
    
    //MARK: - SIMPLE CONVERSIONS
    
    
    public class func getInt16(fromUInt16:UInt16) -> Int16 {
        
        return Int16(bitPattern: fromUInt16)
    }
    
    public class func getUInt16(fromUInt8:UInt8) -> UInt16 {
        return constructUInt16(fromUInt8Pair: [UInt8(0), fromUInt8])
    }
    
    //MARK: - Constructing new bytes or byte arrays -
    
    //https://stackoverflow.com/questions/32830866/how-in-swift-to-convert-int16-to-two-uint8-bytes
    
    
    //MARK: 12-bit
    
    //https://stackoverflow.com/questions/45516517/convert-16-bit-integer-data-to-12-bit-integer-data-in-swift
     //https://stackoverflow.com/questions/39110991/calculating-most-and-least-significant-bytemsb-lsb-with-swift
    
    public class func constructUInt12Array(fromUInt8Array:[UInt8]) -> [UInt16] {
        
        let UInt16Array:[UInt16] = fromUInt8Array.map { getUInt16(fromUInt8: $0) }
        return constructUInt12Array(fromUInt16Array: UInt16Array)
    }
    
    public class func constructUInt12Array(fromUInt16Array:[UInt16]) -> [UInt16] {
        
        //error handling
        if (fromUInt16Array.count % 3 != 0) {
            print("Number: Error: Incoming array cannot be divided evenly by 3, so it cannot become a UInt12 array. Returning []")
            return []
        }
        
        var bytePos:Int = 0
        
        //swift doesn't have a UInt12, so store these values in a UInt16
        var uInt12Array:[UInt16] = []
        
        //loop through incoming array
        //It takes every 3 characters instead of every 2, and packages them together
        for _ in 0..<fromUInt16Array.count {

            if (bytePos >= fromUInt16Array.count) {
                break
            }
            
            if (bytePos % 3 == 0) {
                uInt12Array.append(fromUInt16Array[bytePos] << 4 | fromUInt16Array[bytePos + 1] >> 4);
            
            } else {
                uInt12Array.append((fromUInt16Array[bytePos] & 0xf) << 8 | fromUInt16Array[bytePos + 1]);
                bytePos += 1
            }
            
            bytePos += 1
        }
        
        return uInt12Array
    }
    
    //MARK: - 16-bit
    
    public class func getUInt16(fromBytes: [UInt8]) -> UInt16 {
        
        if (fromBytes.count <= 2) {
            return UInt16(getUInt(fromBytes: fromBytes))
        } else {
            print("Number: getUInt16:fromBytes Error: Incoming array needs to be 2 bytes")
            return 0
        }
    }
    
    public class func constructUInt16(fromUInt8Pair:[UInt8]) -> UInt16 {
        
        return try! UInt16(fromUInt8Pair[0]) << 8 | UInt16(fromUInt8Pair[1])
    }
    
    public class func constructUInt16Array(fromUInt8Array:[UInt8], packetTotal:Int) -> [UInt16] {
    
        let packetLength:Int = 2
        var uint16Array:[UInt16] = []
        var bytePos:Int = 0
        
        //error check
        if (packetTotal > (fromUInt8Array.count / packetLength)) {
            print("Number: Error: Attempting to decode more packets than is available with the incoming data. Returning []")
            return []
        }
        
        for _ in 0..<packetTotal {
        
            //traverse array positions until reaching the end point (which is the curr pos + length)
            let posEnd:Int = bytePos + packetLength

            //init blank array
            var byteArr:[UInt8] = []

            //keep adding bytes until end position is reached
            while bytePos < posEnd {
                byteArr.append(fromUInt8Array[bytePos])
                bytePos += 1
            }

            //convert bytes into a hex
            let uint16:UInt16 = constructUInt16(fromUInt8Pair: byteArr)
            
            //add to uint16 aray
            uint16Array.append(uint16)
        }
        
        return uint16Array
    }
    
    public class func constructInt16Array(fromUInt8Array:[UInt8], packetTotal:Int) -> [Int16] {
    
        //first get UInt16 array
        let uint16Array:[UInt16] = constructUInt16Array(fromUInt8Array: fromUInt8Array, packetTotal: packetTotal)
        
        //process each value into Int16
        return uint16Array.map { getInt16(fromUInt16: $0) }
     
    }
    
    //MARK:- 24-bit
    
    public class func getUInt24(fromBytes: [UInt8]) -> UInt32 {
        
        if (fromBytes.count <= 3) {
            return UInt32(getUInt(fromBytes: fromBytes))
        } else {
            print("Number: getUInt24:fromBytes Error: Incoming array needs to be 3 bytes")
            return 0
        }
    }
    
    public class func constructUInt24Array(fromUInt8Array:[UInt8], packetTotal:Int) -> [UInt32] {
        
        let packetLength:Int = 3
        var uInt24Array:[UInt32] = []
        var bytePos:Int = 0
        
        //error check
        if (fromUInt8Array.count % 3 != 0) {
            print("Number: Error: Incoming array cannot be divided evenly by 3, so it cannot become a UInt12 array. Returning []")
            return []
        }
        
        for _ in 0..<packetTotal {
        
            //traverse array positions until reaching the end point (which is the curr pos + length)
            let posEnd:Int = bytePos + packetLength

            //init blank array
            var byteArr:[UInt8] = []

            //keep adding bytes until end position is reached
            while bytePos < posEnd {
                byteArr.append(fromUInt8Array[bytePos])
                bytePos += 1
            }
            
            //create UInt24 from bytes
            let uInt24FromBytes:UInt32 = getUInt24(fromBytes: byteArr)
            
            //add to array
            uInt24Array.append(uInt24FromBytes)
            
        }
        
        return uInt24Array
    }
    
    
    //MARK: - 32-bit
    
    public class func getUInt32(fromBytes: [UInt8]) -> UInt32 {
        
        if (fromBytes.count <= 4) {
            return UInt32(getUInt(fromBytes: fromBytes))
        } else {
            print("Number: getUInt32:fromBytes Error: Incoming array needs to be 4 bytes")
            return 0
        }
    }
    
    //MARK: - Main UInt Conversion func
    
    //main processor func
    //can create UInt16 from 2 bytes, UInt32 (UInt24) from 3 bytes, and UInt32 from 4 bytes
    public class func getUInt(fromBytes: [UInt8]) -> UInt {
        
        //max number of bytes this can process is 4 (resulting in UInt32)
        if (fromBytes.count <= 4) {
            
            var result:UInt = 0
            
            //loop through byte positions
            for i in 0..<(fromBytes.count) {
                
                //concat values
                let shiftAmount = UInt((fromBytes.count) - i - 1) * 8
                result += UInt(fromBytes[i]) << shiftAmount
            }
            
            return result
            
        } else {
            print("Number: getUInt:fromBytes Error: Incoming array needs to be 4 bytes or less")
            return 0
        }
    }
    
    //MARK: - get hex array REMOVED in favor of UInt conversions
    /*
    public class func getHexArray(fromBytes:[UInt8], packetLength:Int, packetTotal:Int) -> [String] {
        print("fromBytes", fromBytes)
        var hexArray:[String] = []
        var bytePos:Int = 0
        
        //error check
        if (packetTotal > (fromBytes.count / packetLength)) {
            print("Hex: Error: Attempting to decode more packets than is available with the incoming data. Returning []")
            return []
        }
        
        for _ in 0..<packetTotal {
        
            //traverse array positions until reaching the end point (which is the curr pos + length)
            let posEnd:Int = bytePos + packetLength

            //init blank array
            var byteArr:[UInt8] = []

            //keep adding bytes until end position is reached
            while bytePos < posEnd {
                byteArr.append(fromBytes[bytePos])
                bytePos += 1
            }

            //convert bytes into a hex
            let hex:String = Bytes.getHex(fromBytes: byteArr)
            
            //add to hex aray
            hexArray.append(hex)
        }
        print("hexArray", hexArray)
        return hexArray
    }
    
    //MARK: - 2 string hex from 2 bytes packets
    public class func getHex(fromBytes:[UInt8]) -> String {
        
        //convert byte into a hex formatted string and build via concatentation
        return fromBytes.map { String(format: "%02hhx", $0) }.joined()
    }
    
    //MARK: - Unsigned ints from from hex
    
    public class func getUInt8(fromHex:String) -> UInt8? {
        
        //8-bit values need to be 2 chars
        if (fromHex.count == 2) {
            
            //try to convert hex into UInt8
            if let uInt8Value:UInt8 = UInt8(fromHex, radix: 16) {
                
                return uInt8Value
                
            } else {
                return nil
            }
            
        } else {
            print("Hex: Error: Hex needs to be 2 characters long to create an 8-bit value")
            return nil
        }
    }
    
    public class func getUInt16(fromHex:String) -> UInt16? {
        
        //16-bit values need to be 4 chars
        if (fromHex.count == 4) {
            
            //try to convert hex into UInt16
            if let uInt16Value:UInt16 = UInt16(fromHex, radix: 16) {
                
                return uInt16Value
                
            } else {
                return nil
            }
                
        } else {
            print("Hex: Error: Hex needs to be 4 characters long to create an 16-bit value")
            return nil
        }
    }
    */
    
}

