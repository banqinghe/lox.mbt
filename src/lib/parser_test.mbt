test "arithmetic expression" {
    let source = "1 + -2 * 3 - 4 / 5 != 6 < -7"
    let scanner = Scanner::new(source)
    let tokens = scanner.scan_tokens()
    let parser = Parser::new(tokens)
    let result = parser.expression()

    let expected = Expression::Binary(
        left=Expression::Binary(
            left=Expression::Binary(
                left=Expression::Literal(value=Literal::Number(1.0)),
                operator=Token::new(TokenType::PLUS, "+", Literal::Nil, 1, 3),
                right=Expression::Binary(
                    left=Expression::Unary(
                        operator=Token::new(TokenType::MINUS, "-", Literal::Nil, 1, 5),
                        right=Expression::Literal(value=Literal::Number(2.0))
                    ),
                    operator=Token::new(TokenType::STAR, "*", Literal::Nil, 1, 8),
                    right=Expression::Literal(value=Literal::Number(3.0))
                ),
            ),
            operator=Token::new(TokenType::MINUS, "-", Literal::Nil, 1, 12),
            right=Expression::Binary(
                left=Expression::Literal(value=Literal::Number(4.0)),
                operator=Token::new(TokenType::SLASH, "/", Literal::Nil, 1, 16),
                right=Expression::Literal(value=Literal::Number(5.0))
            ),
        ),
        operator=Token::new(TokenType::BANG_EQUAL, "!=", Literal::Nil, 1, 20),
        right=Expression::Binary(
            left=Expression::Literal(value=Literal::Number(6.0)),
            operator=Token::new(TokenType::LESS, "<", Literal::Nil, 1, 25),
            right=Expression::Unary(
                operator=Token::new(TokenType::MINUS, "-", Literal::Nil, 1, 27),
                right=Expression::Literal(value=Literal::Number(7.0))
            )
        ),
    )

    assert_eq(result, expected)
}

test "group and comma expression" {
    let source = "(1 + 2) * 3, (4 + 5)"
    let scanner = Scanner::new(source)
    let tokens = scanner.scan_tokens()
    let parser = Parser::new(tokens)
    let result = parser.expression()

    let expected = Expression::Binary(
        left=Expression::Binary(
            left=Expression::Grouping(
                expression=Expression::Binary(
                    left=Expression::Literal(value=Literal::Number(1.0)),
                    operator=Token::new(TokenType::PLUS, "+", Literal::Nil, 1, 4),
                    right=Expression::Literal(value=Literal::Number(2.0))
                )
            ),
            operator=Token::new(TokenType::STAR, "*", Literal::Nil, 1, 9),
            right=Expression::Literal(value=Literal::Number(3.0))
        ),
        operator=Token::new(TokenType::COMMA, ",", Literal::Nil, 1, 12),
        right=Expression::Grouping(
            expression=Expression::Binary(
                left=Expression::Literal(value=Literal::Number(4.0)),
                operator=Token::new(TokenType::PLUS, "+", Literal::Nil, 1, 17),
                right=Expression::Literal(value=Literal::Number(5.0))
            )
        )
    )

    assert_eq(result, expected)
}

test "conditional expression" {
    let source = "0, 1 > 2.5 ? 3 : 4 ? 5 : 6"
    let scanner = Scanner::new(source)
    let tokens = scanner.scan_tokens()
    let parser = Parser::new(tokens)
    let result = parser.expression()

    let expected = Expression::Binary(
        left=Expression::Literal(value=Literal::Number(0.0)),
        operator=Token::new(TokenType::COMMA, ",", Literal::Nil, 1, 2),
        right=Expression::Conditional(
            condition=Expression::Binary(
                left=Expression::Literal(value=Literal::Number(1.0)),
                operator=Token::new(TokenType::GREATER, ">", Literal::Nil, 1, 6),
                right=Expression::Literal(value=Literal::Number(2.5))
            ),
            consequent=Expression::Literal(value=Literal::Number(3.0)),
            alternative=Expression::Conditional(
                condition=Expression::Literal(value=Literal::Number(4.0)),
                consequent=Expression::Literal(value=Literal::Number(5.0)),
                alternative=Expression::Literal(value=Literal::Number(6.0))
            )
        ),
    )

    assert_eq(result, expected)
}

test "missing left operand +" {
    let source = "+-1"
    let scanner = Scanner::new(source)
    let tokens = scanner.scan_tokens()
    let parser = Parser::new(tokens)

    // Error at '+': Missing left operand for '+' operator.
    let result = parser.expression()

    inspect(result, content="1")
}

test "missing left operand >=" {
    let source = ">= 1"
    let scanner = Scanner::new(source)
    let tokens = scanner.scan_tokens()
    let parser = Parser::new(tokens)

    // Error at '>=': Missing left operand for '>=' operator.
    let result = parser.expression()

    inspect(result, content="1")
}

test "missing left operand ==" {
    let source = "== 1"
    let scanner = Scanner::new(source)
    let tokens = scanner.scan_tokens()
    let parser = Parser::new(tokens)

    // Error at '==': Missing left operand for '==' operator.
    let result = parser.expression()

    inspect(result, content="1")
}

test "missing left operand ," {
    let source = ", 1"
    let scanner = Scanner::new(source)
    let tokens = scanner.scan_tokens()
    let parser = Parser::new(tokens)

    // Error at ',': Missing left operand for ',' operator.
    let result = parser.expression()

    inspect(result, content="1")
}
