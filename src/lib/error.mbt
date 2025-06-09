pub let errorCount: Ref[Int] = { val: 0 }

fn error(line: Int, message: String) -> Unit {
    errorCount.val += 1
    report(line, "", message)
}

fn report(line: Int, location: String, message: String) -> Unit {
    println("[line \{line}] Error \{location}: \{message}")
}
