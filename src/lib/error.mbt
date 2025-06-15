pub suberror ParserError (Token, String) derive(Show)

pub let errorCount: Ref[Int] = { val: 0 }

fn report(line: Int, column: Int, location: String, message: String) -> Unit {
    errorCount.val += 1
    println("[line \{line}:\{column}] Error \{location}: \{message}")
}
