pub struct Parser {
    /// The list of tokens to parse.
    tokens: Array[Token]

    /// The current index in the list of tokens.
    mut current: Int
}

///| Creates a parser instance with the given list of tokens.
pub fn Parser::new(tokens: Array[Token]) -> Parser {
    Parser::{
        tokens,
        current: 0,
    }
}

pub fn Parser::parse(p: Self) -> Expression {
    let expr = try? p.expression()
    match expr {
        Ok(expr) => expr
        Err(_) => {
            // TODO: do not panic and synchronize instead
            panic()
        }
    }
}

///| Returns the current token without advancing the parser.
fn Parser::peek(p: Self) -> Token {
    p.tokens[p.current]
}

///| Returns the most recently consumed token.
fn Parser::previous(p: Self) -> Token {
    p.tokens[p.current - 1]
}

///| Checks if the parser has reached the end of the token stream.
fn Parser::is_at_end(p: Self) -> Bool {
    p.peek().token_type == TokenType::EOF
}

///| Advances the parser to the next token and returns the previous token.
fn Parser::advance(p: Self) -> Token {
    if not(p.is_at_end()) {
        p.current += 1
    }
    p.previous()
}

///| Checks if the current token matches the given token type.
fn Parser::check(p: Self, token_type: TokenType) -> Bool {
    if p.is_at_end() {
        return false
    }
    p.peek().token_type == token_type
}

///| Advances and returns true if the current token matches any of the given types.
fn Parser::matchTo(p: Self, token_types: Array[TokenType]) -> Bool {
    for token_type in token_types {
        if p.check(token_type) {
            ignore(p.advance())
            return true
        }
    }
    false
}

///| Log a parser error with the given token and message, return a ParserError.
fn Parser::error(_: Self, token: Token, message: String) -> ParserError {
    if (token.token_type == TokenType::EOF) {
        report(token.line, "at end", message)
    } else {
        report(token.line, "at '\{token.lexeme}'", message)
    }
    ParserError((token, message))
}

///| Consumes the current token if it matches the given type, otherwise raises a ParserError with the given message.
fn Parser::consume(p: Self, token_type: TokenType, message: String) -> Unit raise ParserError {
    if p.check(token_type) {
        return ignore(p.advance())
    }
    raise p.error(p.peek(), message)
}

///| Synchronizes the parser state by jumping to the next statement,
///  we treat `;` as the end of a statement and some keywords as the beginning of a statement
fn Parser::synchronize(p: Self) -> Unit {
    ignore(p.advance())
    while not(p.is_at_end()) {
        if p.previous().token_type == TokenType::SEMICOLON {
            return
        }
        if p.peek().token_type is (
            TokenType::CLASS | TokenType::FUN | TokenType::VAR |
            TokenType::FOR | TokenType::IF | TokenType::WHILE |
            TokenType::PRINT | TokenType::RETURN
        ) {
            return
        }

        ignore(p.advance())
    }
}

///| expression → conditional ( "," conditional )*
pub fn Parser::expression(p: Self) -> Expression raise ParserError {
    let mut expr = p.conditional()

    while p.matchTo([TokenType::COMMA]) {
        let operator = p.previous()
        let right = p.conditional()
        expr = Expression::Binary(left=expr, operator=operator, right=right)
    }

    expr
}

///| conditional → equality ( "?" expression ":" conditional )?
fn Parser::conditional(p: Self) -> Expression raise ParserError {
    let condition = p.equality()

    if p.matchTo([TokenType::QUESTION]) {
        let consequent = p.expression()
        p.consume(TokenType::COLON, "Expected ':' after '?' in conditional expression")
        let alternative = p.conditional()
        return Expression::Conditional(condition=condition, consequent=consequent, alternative=alternative)
    }

    condition
}

///| equality → comparison ( ( "!=" | "==" ) comparison )*
fn Parser::equality(p: Self) -> Expression raise ParserError {
    let mut expr = p.comparison()

    while p.matchTo([TokenType::BANG_EQUAL, TokenType::EQUAL_EQUAL]) {
        let operator = p.previous()
        let right = p.comparison()
        expr = Expression::Binary(left=expr, operator=operator, right=right)
    }

    expr
}

///| comparison → term ( ( ">" | ">=" | "<" | "<=" ) term )*
fn Parser::comparison(p: Self) -> Expression raise ParserError {
    let mut expr = p.term()

    while p.matchTo([TokenType::GREATER, TokenType::GREATER_EQUAL, TokenType::LESS, TokenType::LESS_EQUAL]) {
        let operator = p.previous()
        let right = p.term()
        expr = Expression::Binary(left=expr, operator=operator, right=right)
    }

    expr
}

// +2 * 3


///| term → factor ( ( "-" | "+" ) factor )*
fn Parser::term(p: Self) -> Expression raise ParserError {
    let mut expr = p.factor()

    while p.matchTo([TokenType::MINUS, TokenType::PLUS]) {
        let operator = p.previous()
        let right = p.factor()
        expr = Expression::Binary(left=expr, operator=operator, right=right)
    }

    expr
}

///| factor → unary ( ( "/" | "*" ) unary )*
fn Parser::factor(p: Self) -> Expression raise ParserError {
    let mut expr = p.unary()

    while p.matchTo([TokenType::SLASH, TokenType::STAR]) {
        let operator = p.previous()
        let right = p.unary()
        expr = Expression::Binary(left=expr, operator=operator, right=right)
    }

    expr
}

///| unary → ( "!" | "-" ) unary
///        | primary
fn Parser::unary(p: Self) -> Expression raise ParserError {
    if p.matchTo([TokenType::BANG, TokenType::MINUS]) {
        let operator = p.previous()
        let right = p.unary()
        return Expression::Unary(operator=operator, right=right)
    }

    p.primary()
}

///| primary → NUMBER | STRING | "true" | "false" | "nil"
///          | "(" expression ")"
fn Parser::primary(p: Self) -> Expression raise ParserError {
    let token = p.advance()
    match token {
        { token_type: TokenType::TRUE, .. } => Expression::Literal(value=Literal::Boolean(true))
        { token_type: TokenType::FALSE, .. } => Expression::Literal(value=Literal::Boolean(false))
        { token_type: TokenType::NUMBER, literal: Literal::Number(num), .. } => Expression::Literal(value=Literal::Number(num))
        { token_type: TokenType::STRING, literal: Literal::String(str), .. } => Expression::Literal(value=Literal::String(str))
        { token_type: TokenType::NIL, .. } => Expression::Literal(value=Literal::Nil)
        { token_type: TokenType::LEFT_PAREN, .. } => {
            let expr = p.expression()
            p.consume(TokenType::RIGHT_PAREN, "Expected ')' after expression")
            Expression::Grouping(expression=expr)
        }
        _ => {
            raise p.error(token, "Expected expression.")
        }
    }
}
