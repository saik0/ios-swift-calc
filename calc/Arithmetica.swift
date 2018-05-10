//
//  Calc.swift
//  calc
//
//  Created by Joel Pedraza on 5/7/18.
//  Copyright © 2018 Joel Pedraza. All rights reserved.
//


import Foundation

extension Double {
    var format: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

enum Token: CustomStringConvertible {
    case leftParen
    case rightParen
    case minus
    case plus
    case slash
    case star
    case literal(Double)
    
    var description : String {
        switch self {
        case .leftParen: return "("
        case .rightParen: return ")"
        case .minus: return "-"
        case .plus: return "+"
        case .slash: return "/"
        case .star: return "*"
        case .literal(let value): return "\(value.format)"
        }
    }
}


func isAsciiDigit(char: Character) -> Bool {
    return "0"..."9" ~= char
}

enum ScanError: Error {
    case invalidToken(pos: String.Index)
}

func scan(text: String) throws -> Array<Token> {
    let end = text.endIndex
    
    var tokens: Array<Token> = []
    var i = text.startIndex
    
    func hasNext() -> Bool {
        return i < end
    }
    
    func advance() {
        i = text.index(after: i)
    }
    
    /*
     * There is some duplication in peek and peekNext, but I still like it
     * more than allowing arbitrary levels of lookahead
     */
    func peek() -> Character {
        if (!hasNext()) {
            return "\0"
        }
        
        let next = text.index(after: i)
        if (next >= end) {
            return "\0"
        }
        return text[next]
    }
    
    func peekNext() -> Character {
        if (!hasNext()) {
            return "\0"
        }
        
        let next = text.index(after: i)
        if (next >= end) {
            return "\0"
        }
        
        let next2 = text.index(after: next)
        if (next2 >= end) {
            return "\0"
        }
        return text[next2]
    }
    
    func readNumber() -> Token {
        let start = i
        
        // Consume the whole part
        while (isAsciiDigit(char: peek()))  {
            advance()
        }
        
        // Checkif there is a fractional part by looking ahead two characters
        if (peek() == "." && isAsciiDigit(char: peekNext())) {
            // Consume the "."
            advance()
            
            // Consume the whole part
            while (isAsciiDigit(char: peek())) {
                advance()
            }
        }
        
        // We know the substring from start..i is of the form [0-9]+(.[0-9]+)?
        // Unwrapping the option is guaranteed to be safe
        return Token.literal(Double(text[start...i])!)
    }
    
    while hasNext() {
        let c = text[i]
        
        switch (c) {
        case "(" : tokens.append(Token.leftParen)
        case ")" : tokens.append(Token.rightParen)
        case "-" : tokens.append(Token.minus)
        case "+" : tokens.append(Token.plus)
        case "/" : tokens.append(Token.slash)
        case "*" : tokens.append(Token.star)
        case " ",
             "\t",
             "\r",
             "\n":
            break
        default :
            if(isAsciiDigit(char: c)
                || (c == "." && isAsciiDigit(char: peek())) ) {
                tokens.append(readNumber())
            } else {
                throw ScanError.invalidToken(pos: i)
            }
        }
        
        advance()
    }
    
    return tokens
}


enum Expr: CustomStringConvertible {
    case num(Double)
    indirect case neg(Expr)
    indirect case sub(Expr, Expr)
    indirect case add(Expr, Expr)
    indirect case mul(Expr, Expr)
    indirect case div(Expr, Expr)
    
    var description : String {
        switch self {
        case .num(let v): return "\(v.format)"
        case .neg(let e): return "(- \(e))"
        case .sub(let l, let r): return "(- \(l) \(r))"
        case .add(let l, let r): return "(+ \(l) \(r))"
        case .mul(let l, let r): return "(* \(l) \(r))"
        case .div(let l, let r): return "(/ \(l) \(r))"
        }
    }
}

enum ParseError: Error {
    case noToken
    case unexpectedToken
}

func parse(tokens: Array<Token>) throws -> Expr {
    // State
    
    var i = 0
    
    // Helpers
    
    func hasNext() -> Bool {
        return i < tokens.count
    }
    
    func peek() -> Token? {
        if (hasNext()) {
            return tokens[i]
        }
        
        return nil
    }
    
    func advance() {
        if (hasNext()) {
            i += 1
        }
    }
    
    func curryRule(binary: @escaping () throws -> Expr) -> (Expr, (Expr, Expr) -> Expr) throws -> Expr {
        func next(expr: Expr, f: (Expr, Expr) -> Expr, rule: () throws -> Expr) rethrows -> Expr {
            advance()
            return try f(expr, rule())
        }
        
        func inner(expr: Expr, f: (Expr, Expr) -> Expr) throws -> Expr {
            return try next(expr: expr, f: f, rule: binary)
        }
        
        return inner
    }
    
    func curryRule(unary: @escaping () throws -> Expr) -> ((Expr) -> Expr) throws -> Expr {
        func next(f: (Expr) -> Expr, rule: () throws -> Expr) rethrows -> Expr {
            advance()
            return f(try rule())
        }
        
        func inner(f: (Expr) -> Expr) throws -> Expr {
            return try next(f: f, rule: unary)
        }
        
        return inner
    }
    
    
    
    // The recursion
    
    func expression() throws ->  Expr {
        return try addition()
    }
    
    func addition() throws ->  Expr {
        let rule = multiplication
        let nextRule = curryRule(binary: rule)
        
        var expr = try rule()
        
        loop: while true {
            switch ( peek()) {
            case .plus?:  expr = try nextRule(expr, Expr.add)
            case .minus?: expr = try nextRule(expr, Expr.sub)
            default:      break loop
            }
        }
        
        return expr
    }
    
    func multiplication() throws -> Expr {
        let rule = unary
        let nextRule = curryRule(binary: rule)
        
        var expr = try rule()
        
        loop: while true {
            switch (peek()) {
            case .star?:  expr = try nextRule(expr, Expr.mul)
            case .slash?: expr = try nextRule(expr, Expr.div)
            default:      break loop
            }
        }
        
        return expr
    }
    
    func unary() throws ->  Expr {
        let nextRule = curryRule(unary: unary)
        
        switch (peek()) {
        case .minus?: return try nextRule(Expr.neg)
        default:      return try primary()
        }
    }
    
    func primary() throws -> Expr {
        switch (peek()) {
        case .literal(let value)?:
            advance()
            return Expr.num(value)
        case .leftParen?:
            advance()
            let expr = try expression()
            switch (peek()) {
            case .rightParen?:
                advance()
                return expr
            default:
                throw ParseError.unexpectedToken
            }
        default:
            throw ParseError.noToken
        }
    }
    
    let ast = try expression()
    
    if (hasNext()) {
        throw ParseError.unexpectedToken
    }
    
    return ast
}

/// Evaluates an arithmetic expression
func eval(expr: Expr) -> Double {
    switch expr {
    case Expr.num(let value):
        return value
    case .neg(let expr):
        return -eval(expr: expr)
    case .sub(let left, let right):
        return eval(expr: left) - eval(expr: right)
    case .add(let left, let right):
        return eval(expr: left) + eval(expr: right)
    case .mul(let left, let right):
        return eval(expr: left) * eval(expr: right)
    case .div(let left, let right):
        return eval(expr: left) / eval(expr: right)
    }
}
