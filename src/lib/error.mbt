pub suberror ParserError (Token, String)

pub let errorCount: Ref[Int] = { val: 0 }

fn error(line: Int, message: String) -> Unit {
    report(line, "", message)
}

fn report(line: Int, location: String, message: String) -> Unit {
    errorCount.val += 1
    println("[line \{line}] Error \{location}: \{message}")
}
