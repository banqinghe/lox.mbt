test "operators" {
    let scanner = Scanner::new("! != = == > >= < <=")
    let actual_tokens = scanner.scan_tokens()
    let expected_tokens = [
        Token::new(BANG, "!", Literal::Nil, 1, 1),
        Token::new(BANG_EQUAL, "!=", Literal::Nil, 1, 3),
        Token::new(EQUAL, "=", Literal::Nil, 1, 6),
        Token::new(EQUAL_EQUAL, "==", Literal::Nil, 1, 8),
        Token::new(GREATER, ">", Literal::Nil, 1, 11),
        Token::new(GREATER_EQUAL, ">=", Literal::Nil, 1, 13),
        Token::new(LESS, "<", Literal::Nil, 1, 16),
        Token::new(LESS_EQUAL, "<=", Literal::Nil, 1, 18),
        Token::new(EOF, "", Literal::Nil, 1, 20),
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
//         Token::new(BANG, "!", Literal::Nil, 1, 1),
//         Token::new(STAR, "*", Literal::Nil, 1, 15),
//         Token::new(LESS, "<", Literal::Nil, 2, 1),
//         Token::new(GREATER, ">", Literal::Nil, 2, 3),
//         Token::new(STAR, "*", Literal::Nil, 2, 7),
//         Token::new(EOF, "", Literal::Nil, 2, 8),
//     ]
//     assert_eq!(actual_tokens, expected_tokens)
// }

test "comments" {
    let source = "// ha"
    let scanner = Scanner::new(source)
    let actual_tokens = scanner.scan_tokens()
    let expected_tokens = [
        Token::new(EOF, "", Literal::Nil, 1, 6),
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
        Token::new(LEFT_PAREN, "(", Literal::Nil, 2, 1),
        Token::new(LEFT_PAREN, "(", Literal::Nil, 2, 2),
        Token::new(RIGHT_PAREN, ")", Literal::Nil, 2, 4),
        Token::new(RIGHT_PAREN, ")", Literal::Nil, 2, 5),
        Token::new(LEFT_BRACE, "{", Literal::Nil, 2, 6),
        Token::new(RIGHT_BRACE, "}", Literal::Nil, 2, 7),
        Token::new(BANG, "!", Literal::Nil, 3, 1),
        Token::new(STAR, "*", Literal::Nil, 3, 2),
        Token::new(PLUS, "+", Literal::Nil, 3, 3),
        Token::new(MINUS, "-", Literal::Nil, 3, 4),
        Token::new(SLASH, "/", Literal::Nil, 3, 5),
        Token::new(EQUAL, "=", Literal::Nil, 3, 6),
        Token::new(LESS, "<", Literal::Nil, 3, 7),
        Token::new(GREATER, ">", Literal::Nil, 3, 8),
        Token::new(LESS_EQUAL, "<=", Literal::Nil, 3, 10),
        Token::new(EQUAL_EQUAL, "==", Literal::Nil, 3, 13),
        Token::new(VAR, "var", Literal::Nil, 4, 1),
        Token::new(IDENTIFIER, "a", Literal::Nil, 4, 16),
        Token::new(EOF, "", Literal::Nil, 4, 17),
    ]
    assert_eq!(actual_tokens, expected_tokens)
}

test "string literals" {
    let source = "\"hello, world!\" \"moon\""
    let scanner = Scanner::new(source)
    let actual_tokens = scanner.scan_tokens()
    let expected_tokens = [
        Token::new(STRING, "\"hello, world!\"", Literal::String("hello, world!".to_string()), 1, 1),
        Token::new(STRING, "\"moon\"", Literal::String("moon".to_string()), 1, 17),
        Token::new(EOF, "", Literal::Nil, 1, 23),
    ]
    assert_eq!(actual_tokens, expected_tokens)
}

test "number literals" {
    let source = "123 456.789 262\n 213"
    let scanner = Scanner::new(source)
    let actual_tokens = scanner.scan_tokens()
    let expected_tokens = [
        Token::new(NUMBER, "123", Literal::Number(123.0), 1, 1),
        Token::new(NUMBER, "456.789", Literal::Number(456.789), 1, 5),
        Token::new(NUMBER, "262", Literal::Number(262.0), 1, 13),
        Token::new(NUMBER, "213", Literal::Number(213.0), 2, 2),
        Token::new(EOF, "", Literal::Nil, 2, 5),
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
        Token::new(AND, "and", Literal::Nil, 1, 1),
        Token::new(CLASS, "class", Literal::Nil, 1, 5),
        Token::new(ELSE, "else", Literal::Nil, 1, 11),
        Token::new(FALSE, "false", Literal::Nil, 1, 16),
        Token::new(FUN, "fun", Literal::Nil, 1, 22),
        Token::new(FOR, "for", Literal::Nil, 1, 26),
        Token::new(NIL, "nil", Literal::Nil, 2, 1),
        Token::new(OR, "or", Literal::Nil, 2, 5),
        Token::new(PRINT, "print", Literal::Nil, 2, 8),
        Token::new(RETURN, "return", Literal::Nil, 2, 14),
        Token::new(SUPER, "super", Literal::Nil, 2, 21),
        Token::new(THIS, "this", Literal::Nil, 2, 27),
        Token::new(TRUE, "true", Literal::Nil, 3, 1),
        Token::new(VAR, "var", Literal::Nil, 3, 6),
        Token::new(IDENTIFIER, "myVar", Literal::Nil, 3, 10),
        Token::new(IF, "if", Literal::Nil, 3, 16),
        Token::new(ELSE, "else", Literal::Nil, 3, 19),
        Token::new(TRUE, "true", Literal::Nil, 3, 24),
        Token::new(FALSE, "false", Literal::Nil, 3, 29),
        Token::new(NIL, "nil", Literal::Nil, 3, 35),
        Token::new(IDENTIFIER, "truefalse", Literal::Nil, 4, 1),
        Token::new(IDENTIFIER, "printFoo", Literal::Nil, 4, 11),
        Token::new(EOF, "", Literal::Nil, 4, 19),
    ]
    assert_eq!(actual_tokens, expected_tokens)
}
