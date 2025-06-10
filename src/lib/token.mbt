pub(all) enum TokenType {
    // Single-character tokens.
    LEFT_PAREN
    RIGHT_PAREN
    LEFT_BRACE
    RIGHT_BRACE
    COMMA
    DOT
    MINUS
    PLUS
    SEMICOLON
    SLASH
    STAR

    // One or two character tokens.
    BANG
    BANG_EQUAL
    EQUAL
    EQUAL_EQUAL
    GREATER
    GREATER_EQUAL
    LESS
    LESS_EQUAL

    // Literals.
    IDENTIFIER
    STRING
    NUMBER

    // Keywords.
    AND
    CLASS
    ELSE
    FALSE
    FUN
    FOR
    IF
    NIL
    OR
    PRINT
    RETURN
    SUPER
    THIS
    TRUE
    VAR
    WHILE

    EOF
} derive(Show, Eq)

pub let keywords: Map[String, TokenType] = Map::of([
    ("and",     TokenType::AND),
    ("class",   TokenType::CLASS),
    ("else",    TokenType::ELSE),
    ("false",   TokenType::FALSE),
    ("fun",     TokenType::FUN),
    ("for",     TokenType::FOR),
    ("if",      TokenType::IF),
    ("nil",     TokenType::NIL),
    ("or",      TokenType::OR),
    ("print",   TokenType::PRINT),
    ("return",  TokenType::RETURN),
    ("super",   TokenType::SUPER),
    ("this",    TokenType::THIS),
    ("true",    TokenType::TRUE),
    ("var",     TokenType::VAR),
    ("while",   TokenType::WHILE)
]);

pub(all) enum Literal {
    String(String)
    Number(Double)
    Nil
} derive(Show, Eq)

pub struct Token {
    token_type: TokenType
    lexeme: String
    literal: Literal
    line: Int
    column: Int
} derive(Show, Eq)

pub fn Token::new(token_type: TokenType, lexeme: String, literal: Literal, line: Int, column: Int) -> Token {
    Token::{
        token_type,
        lexeme,
        literal,
        line,
        column,
    }
}
