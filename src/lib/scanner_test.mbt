test "operators" {
    let scanner = Scanner::new("! != = == > >= < <=")
    let actual_tokens = scanner.scan_tokens()
    let expected_tokens = [
        Token::new(BANG, "!", LiteralNil, 1, 1),
        Token::new(BANG_EQUAL, "!=", LiteralNil, 1, 3),
        Token::new(EQUAL, "=", LiteralNil, 1, 6),
        Token::new(EQUAL_EQUAL, "==", LiteralNil, 1, 8),
        Token::new(GREATER, ">", LiteralNil, 1, 11),
        Token::new(GREATER_EQUAL, ">=", LiteralNil, 1, 13),
        Token::new(LESS, "<", LiteralNil, 1, 16),
        Token::new(LESS_EQUAL, "<=", LiteralNil, 1, 18),
        Token::new(EOF, "", LiteralNil, 1, 20),
    ]
    assert_eq!(actual_tokens, expected_tokens)
}

// I don't want to get annoying error messages for unexpected characters,
// so this test is commented out (but I have tried it before, and it worked)
// test "unexpected character" {
//     let source = 
//         #|! @ # $ % ^ & *
//         #|< > | *
//     let scanner = Scanner::new(source)
//     let actual_tokens = scanner.scan_tokens()
//     let expected_tokens = [
//         Token::new(BANG, "!", LiteralNil, 1, 1),
//         Token::new(STAR, "*", LiteralNil, 1, 15),
//         Token::new(LESS, "<", LiteralNil, 2, 1),
//         Token::new(GREATER, ">", LiteralNil, 2, 3),
//         Token::new(STAR, "*", LiteralNil, 2, 7),
//         Token::new(EOF, "", LiteralNil, 2, 8),
//     ]
//     assert_eq!(actual_tokens, expected_tokens)
// }

test "comments" {
    let source = "// ha"
    let scanner = Scanner::new(source)
    let actual_tokens = scanner.scan_tokens()
    let expected_tokens = [
        Token::new(EOF, "", LiteralNil, 1, 6),
    ]
    assert_eq!(actual_tokens, expected_tokens)
}

test "lines with comments" {
    let source =
        #|// this is a comment
        #|(( )){} // grouping stuff
        #|!*+-/=<> <= == // operators
        #|var /* what */ a
    let scanner = Scanner::new(source)
    let actual_tokens = scanner.scan_tokens()
    let expected_tokens = [
        Token::new(LEFT_PAREN, "(", LiteralNil, 2, 1),
        Token::new(LEFT_PAREN, "(", LiteralNil, 2, 2),
        Token::new(RIGHT_PAREN, ")", LiteralNil, 2, 4),
        Token::new(RIGHT_PAREN, ")", LiteralNil, 2, 5),
        Token::new(LEFT_BRACE, "{", LiteralNil, 2, 6),
        Token::new(RIGHT_BRACE, "}", LiteralNil, 2, 7),
        Token::new(BANG, "!", LiteralNil, 3, 1),
        Token::new(STAR, "*", LiteralNil, 3, 2),
        Token::new(PLUS, "+", LiteralNil, 3, 3),
        Token::new(MINUS, "-", LiteralNil, 3, 4),
        Token::new(SLASH, "/", LiteralNil, 3, 5),
        Token::new(EQUAL, "=", LiteralNil, 3, 6),
        Token::new(LESS, "<", LiteralNil, 3, 7),
        Token::new(GREATER, ">", LiteralNil, 3, 8),
        Token::new(LESS_EQUAL, "<=", LiteralNil, 3, 10),
        Token::new(EQUAL_EQUAL, "==", LiteralNil, 3, 13),
        Token::new(VAR, "var", LiteralNil, 4, 1),
        Token::new(IDENTIFIER, "a", LiteralNil, 4, 16),
        Token::new(EOF, "", LiteralNil, 4, 17),
    ]
    assert_eq!(actual_tokens, expected_tokens)
}

test "string literals" {
    let source = "\"hello, world!\" \"moon\""
    let scanner = Scanner::new(source)
    let actual_tokens = scanner.scan_tokens()
    let expected_tokens = [
        Token::new(STRING, "\"hello, world!\"", LiteralString("hello, world!".to_string()), 1, 1),
        Token::new(STRING, "\"moon\"", LiteralString("moon".to_string()), 1, 17),
        Token::new(EOF, "", LiteralNil, 1, 23),
    ]
    assert_eq!(actual_tokens, expected_tokens)
}

test "number literals" {
    let source = "123 456.789 262\n 213"
    let scanner = Scanner::new(source)
    let actual_tokens = scanner.scan_tokens()
    let expected_tokens = [
        Token::new(NUMBER, "123", LiteralNumber(123.0), 1, 1),
        Token::new(NUMBER, "456.789", LiteralNumber(456.789), 1, 5),
        Token::new(NUMBER, "262", LiteralNumber(262.0), 1, 13),
        Token::new(NUMBER, "213", LiteralNumber(213.0), 2, 2),
        Token::new(EOF, "", LiteralNil, 2, 5),
    ]
    assert_eq!(actual_tokens, expected_tokens)
}

test "identifiers and keywords" {
    let source =
        #|and class else false fun for
        #|nil or print return super this
        #|true var myVar if else true false nil
        #|truefalse printFoo
    let scanner = Scanner::new(source)
    let actual_tokens = scanner.scan_tokens()
    let expected_tokens = [
        Token::new(AND, "and", LiteralNil, 1, 1),
        Token::new(CLASS, "class", LiteralNil, 1, 5),
        Token::new(ELSE, "else", LiteralNil, 1, 11),
        Token::new(FALSE, "false", LiteralNil, 1, 16),
        Token::new(FUN, "fun", LiteralNil, 1, 22),
        Token::new(FOR, "for", LiteralNil, 1, 26),
        Token::new(NIL, "nil", LiteralNil, 2, 1),
        Token::new(OR, "or", LiteralNil, 2, 5),
        Token::new(PRINT, "print", LiteralNil, 2, 8),
        Token::new(RETURN, "return", LiteralNil, 2, 14),
        Token::new(SUPER, "super", LiteralNil, 2, 21),
        Token::new(THIS, "this", LiteralNil, 2, 27),
        Token::new(TRUE, "true", LiteralNil, 3, 1),
        Token::new(VAR, "var", LiteralNil, 3, 6),
        Token::new(IDENTIFIER, "myVar", LiteralNil, 3, 10),
        Token::new(IF, "if", LiteralNil, 3, 16),
        Token::new(ELSE, "else", LiteralNil, 3, 19),
        Token::new(TRUE, "true", LiteralNil, 3, 24),
        Token::new(FALSE, "false", LiteralNil, 3, 29),
        Token::new(NIL, "nil", LiteralNil, 3, 35),
        Token::new(IDENTIFIER, "truefalse", LiteralNil, 4, 1),
        Token::new(IDENTIFIER, "printFoo", LiteralNil, 4, 11),
        Token::new(EOF, "", LiteralNil, 4, 19),
    ]
    assert_eq!(actual_tokens, expected_tokens)
}
