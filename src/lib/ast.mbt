pub(all) enum Expression {
    Binary(left~: Expression, operator~: Token, right~: Expression)
    Grouping(expression~: Expression)
    Literal(value~: Literal)
    Unary(operator~: Token, right~: Expression)
    Conditional(condition~: Expression, consequent~: Expression, alternative~: Expression)
} derive(Eq)

///| pretty print for each expression
pub impl Show for Expression with output(self, logger) {
    match self {
        /// (operator left right)
        Expression::Binary(left~, operator~, right~) => {
            logger
                ..write_char('(')
                ..write_string(operator.lexeme)
                ..write_char(' ')
                ..write_string(left.to_string())
                ..write_char(' ')
                ..write_string(right.to_string())
                ..write_char(')')
        }
        /// (group expression)
        Expression::Grouping(expression~) => {
            logger
                ..write_char('(')
                ..write_string("group")
                ..write_char(' ')
                ..write_string(expression.to_string())
                ..write_char(')')
        }
        /// literal value
        Expression::Literal(value~) => {
            match value {
                Literal::String(string) => logger.write_string(string)
                Literal::Number(number) => logger.write_string(number.to_string())
                Literal::Boolean(boolean) => logger.write_string(boolean.to_string())
                Literal::Nil => logger.write_string("nil")
            }
        }
        /// (operator right)
        Expression::Unary(operator~, right~) => {
            logger
                ..write_char('(')
                ..write_string(operator.lexeme)
                ..write_char(' ')
                ..write_string(right.to_string())
                ..write_char(')')
        }
        /// (condition consequent alternative)
        Expression::Conditional(condition~, consequent~, alternative~) => {
            logger
                ..write_char('(')
                ..write_string("conditional")
                ..write_char(' ')
                ..write_string(condition.to_string())
                ..write_string(" (")
                ..write_string(consequent.to_string())
                ..write_string(" or ")
                ..write_string(alternative.to_string())
                ..write_string("))")
        }
    }
}
