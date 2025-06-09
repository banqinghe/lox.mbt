pub struct Scanner {
    /// The source code to be scanned.
    source: String

    /// The list of tokens that have been scanned from the source code.
    tokens: Array[Token]

    /// The starting index of the current token in the source code.
    mut start: Int

    /// The current index in the source code.
    mut current: Int

    /// The current column number in the source code.
    mut column: Int

    /// The current line number in the source code.
    mut line: Int
}

pub fn Scanner::new(source: String) -> Scanner {
    Scanner::{
        source,
        tokens: [],
        start: 0,
        current: 0,
        column: 0,
        line: 1,
    }
}

fn Scanner::is_at_end(scanner: Scanner) -> Bool {
    scanner.current >= scanner.source.length()
}

fn Scanner::add_token(scanner: Scanner, token_type: TokenType, literal: Literal, start_column~: Int = scanner.column) -> Unit {
    let (lexeme, column) = match token_type {
        EOF => ("", scanner.column + 1)
        _ => (
            scanner.source.substring(start=scanner.start, end=scanner.current),
            start_column
        )
    }

    let token = Token::new(
        token_type,
        lexeme,
        literal,
        scanner.line,
        column,
    )
    scanner.tokens.push(token)
}

///| Advance the scanner to the next character and return the character.
fn Scanner::advance(scanner: Scanner) -> Char {
    let char = scanner.source.char_at(scanner.current)
    scanner.current += 1
    scanner.column += 1
    char
}

///| Check the next character without consuming it.
/// > It’s sort of like `advance()`, but doesn’t consume the character. This is called **lookahead**
fn Scanner::peek(scanner: Scanner) -> Char? {
    if scanner.is_at_end() {
        return None
    }
    Some(scanner.source.char_at(scanner.current))
}

///| Check the character after the next one without consuming it.
fn Scanner::peek_next(scanner: Scanner) -> Char? {
    if scanner.current + 1 >= scanner.source.length() {
        return None
    }
    Some(scanner.source.char_at(scanner.current + 1))
}

///| Check if the next character matches the expected one and consume it if it does.
/// > Technically, `match_next()` is doing lookahead too. `advance()` and `peek()` are the fundamental operators and match_next() combines them.
fn Scanner::match_next(scanner: Scanner, expected: Char) -> Bool {
    if scanner.is_at_end() || scanner.source.char_at(scanner.current) != expected {
        return false
    }
    scanner.current += 1
    scanner.column += 1
    true
}

fn Scanner::string(scanner: Scanner) -> Unit {
    let start_column = scanner.column

    while scanner.peek() != Some('"') && not(scanner.is_at_end()) {
        if scanner.peek() == Some('\n') {
            scanner.line += 1
            scanner.column = 0
        }
        ignore(scanner.advance())
    }
    if scanner.is_at_end() {
        error(scanner.line, "Unterminated string.")
        return
    }

    // The closing quote.
    ignore(scanner.advance())

    let string_content = scanner.source.substring(start=scanner.start + 1, end=scanner.current - 1)
    scanner.add_token(STRING, LiteralString(string_content), start_column=start_column)
}

fn Scanner::number(scanner: Scanner) -> Unit {
    let start_column = scanner.column

    fn consume_digits(scanner: Scanner) -> Unit {
        while scanner.peek() is Some(c) && c.is_digit(10) {
            ignore(scanner.advance())
        }
    }

    // Consume the integer part.
    consume_digits(scanner)

    if scanner.peek() == Some('.') && scanner.peek_next() is Some(c) && c.is_digit(10) {
        // Consume the '.'
        ignore(scanner.advance())
        // Consume the digits after the '.'
        consume_digits(scanner)
    }

    let actual_number = @strconv.parse_double?(scanner.source.substring(start=scanner.start, end=scanner.current))
    guard actual_number.is_ok()

    scanner.add_token(
        NUMBER,
        LiteralNumber(actual_number.unwrap()),
        start_column=start_column
    )
}

fn Scanner::identifier(scanner: Scanner) -> Unit {
    let start_column = scanner.column

    while scanner.peek() is Some(c) && c is ('a'..='z' | 'A'..='Z' | '_' | '0'..='9') {
        ignore(scanner.advance())
    }

    let text = scanner.source.substring(start=scanner.start, end=scanner.current)
    let token_type = match keywords.get(text) {
        Some(token_type) => token_type
        None => IDENTIFIER
    }
    scanner.add_token(
        token_type,
        LiteralNil, // Identifiers do not have a literal value.
        start_column=start_column
    )
}

fn Scanner::scan_token(scanner: Scanner) -> Unit {
    match scanner.advance() {
        '(' => scanner.add_token(LEFT_PAREN, LiteralNil)
        ')' => scanner.add_token(RIGHT_PAREN, LiteralNil)
        '{' => scanner.add_token(LEFT_BRACE, LiteralNil)
        '}' => scanner.add_token(RIGHT_BRACE, LiteralNil)
        ',' => scanner.add_token(COMMA, LiteralNil)
        '.' => scanner.add_token(DOT, LiteralNil)
        '-' => scanner.add_token(MINUS, LiteralNil)
        '+' => scanner.add_token(PLUS, LiteralNil)
        ';' => scanner.add_token(SEMICOLON, LiteralNil)
        '*' => scanner.add_token(STAR, LiteralNil)
        '!' => {
            if scanner.match_next('=') {
                scanner.add_token(BANG_EQUAL, LiteralNil, start_column=scanner.column - 1)
            } else {
                scanner.add_token(BANG, LiteralNil)
            }
        }
        '=' => {
            if scanner.match_next('=') {
                scanner.add_token(EQUAL_EQUAL, LiteralNil, start_column=scanner.column - 1)
            } else {
                scanner.add_token(EQUAL, LiteralNil)
            }
        }
        '<' => {
            if scanner.match_next('=') {
                scanner.add_token(LESS_EQUAL, LiteralNil, start_column=scanner.column - 1)
            } else {
                scanner.add_token(LESS, LiteralNil)
            }
        }
        '>' => {
            if scanner.match_next('=') {
                scanner.add_token(GREATER_EQUAL, LiteralNil, start_column=scanner.column - 1)
            } else {
                scanner.add_token(GREATER, LiteralNil)
            }
        }
        '/' => {
            if scanner.match_next('/') {
                // A comment goes until the end of the line.
                while scanner.peek() != Some('\n') && not(scanner.is_at_end()) {
                    ignore(scanner.advance())
                }
            } else if scanner.match_next('*') {
                // A multi-line comment starts with /* and ends with */
                while not(scanner.is_at_end()) {
                    if scanner.peek() == Some('*') && scanner.peek_next() == Some('/') {
                        ignore(scanner.advance()) // Consume the '*'.
                        ignore(scanner.advance()) // Consume the '/'.
                        break
                    }
                    ignore(scanner.advance())
                }
            } else {
                scanner.add_token(SLASH, LiteralNil)
            }
        }
        '"' => {
            scanner.string()
        }
        ' ' | '\r' | '\t' => ()
        '\n' => {
            scanner.line += 1
            scanner.column = 0
        }
        c => {
            ignore(c.is_ascii_lowercase() || c.is_ascii_uppercase() || c == '_') // Ignore any other whitespace characters.
            match c {
                '0'..='9' => {
                    // If the character is a digit, we start scanning a number.
                    scanner.number()
                }
                'a'..='z' | 'A'..='Z' | '_' => {
                    // An identifier or keyword starts with a letter or underscore.
                    scanner.identifier()
                }
                _ => {
                    error(scanner.line, "Unexpected character: \{scanner.source.char_at(scanner.current - 1)} line \{scanner.line}, column \{scanner.column}")
                }
            }
        }
    }
}

pub fn Scanner::scan_tokens(scanner: Scanner) -> Array[Token] {
    while not(scanner.is_at_end()) {
        scanner.start = scanner.current
        scanner.scan_token()
    }
    scanner.add_token(EOF, LiteralNil)
    scanner.tokens
}
