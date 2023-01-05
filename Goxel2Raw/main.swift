//
//  main.swift
//  Goxel2Raw
//
//  Created by peterappleby on 1/4/23.
//

import Foundation
import SwiftUI


// Stupid Swift does NOT have fixed arrays even in a single
//  dimension, much less three. D'oh!

let x:Int = 32
let y:Int = 32
let z:Int = 32

var buffer:Data = Data.init(count: x*y*z)


//read text file line by line
func readFile(_ path: String) -> Int {
    errno = 0
    if freopen(path, "r", stdin) == nil {
        perror(path)
        return 1
    }
    
    while let line = readLine() {

        if ( line.count >= 1 )
        {
            if ( line.first == "#" )
            {
                // skip
            }
            else
            {
                let lineItems = line.split(separator: " ")
                if ( lineItems.count == 4 )
                {
                    let i: Int = Int(lineItems[0])! + 1
                    let j: Int = Int(lineItems[1])! + 1
                    let k: Int = Int(lineItems[2])! + 1
                    let c: String = String(lineItems[3])
                    
                    let color = colorWithHexString(hexString: c)
                    
                    let r = color.redComponent
                    let g = color.greenComponent
                    let b = color.blueComponent
                                            
                    let l = ( r * 0.2126 ) + ( g * 0.7152 ) + ( b * 0.0722 )      // luminance
                    let a = UInt8( l * 100 )
                    
                    let n:Int = ( i - 1 ) + ( j - 1 ) * x + ( k - 1 ) * x * y
                    
                    buffer[n] = a
                    
                    print("\(i), \(j), \(k), \(n), \(c), \(r), \(g), \(b), \(a) ")
                }
            }
        }
    }
    return 0
}

func writeFile(_ path: String) -> Int {
    errno = 0
    
    let fp = fopen(path, "wb+")
    if fp == nil {
        perror(path)
        return 1
    }
    
    for i in 1...x
    {
        for j in 1...y
        {
            for k in 1...z
            {
                let n:Int = ( i - 1 ) + ( j - 1 ) * x + ( k - 1 ) * x * y
                
                var a = buffer[n]
                
                fwrite(&a, 1, 1, fp);
            }
        }
    }
 
    fclose(fp)
    
    return 0
}


// https://stackoverflow.com/questions/1560081/how-can-i-create-a-uicolor-from-a-hex-string

func colorWithHexString(hexString: String, alpha:CGFloat = 1.0) -> NSColor {

    // Convert hex string to an integer
    let hexint = Int(intFromHexString(hexStr: hexString))
    let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
    let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
    let blue = CGFloat((hexint & 0xff) >> 0) / 255.0

    // Create color object, specifying alpha as well
    let color = NSColor(red: red, green: green, blue: blue, alpha: alpha)
    return color
}

func intFromHexString(hexStr: String) -> UInt32 {
    var hexInt: UInt32 = 0
    // Create scanner
    let scanner: Scanner = Scanner(string: hexStr)
    // Tell scanner to skip the # character
    scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
    // Scan hex value
    hexInt = UInt32(bitPattern: scanner.scanInt32(representation: .hexadecimal) ?? 0)
    return hexInt
}

var inPath = "/Users/peterappleby/Documents/Mod Synth/Apple/Goxel2Raw/Goxel2Raw/GoxelExport.txt"
var outPath = "/Users/peterappleby/Documents/Mod Synth/Apple/Goxel2Raw/Goxel2Raw/GoxelExport.raw"

let _ = readFile(inPath)
let _ = writeFile(outPath)
