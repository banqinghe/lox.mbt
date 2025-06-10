test "pretty print expression" {
    let expression = Expression::Binary(
        left=Expression::Unary(
            operator=Token::new(TokenType::MINUS, "-", Literal::Nil, 1, 1),
            right=Expression::Literal(value=Literal::Number(123)),
        ),
        operator=Token::new(TokenType::STAR, "*", Literal::Nil, 1, 3),
        right=Expression::Grouping(expression=Expression::Literal(value=Literal::Number(45.67)))
    )
    assert_eq!(expression.to_string(), "(* (- 123) (group 45.67))")
}
