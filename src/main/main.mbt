fn main {
    let args = @env.args()
    println(args)
    if args.length() != 2 {
        println("Usage: moon run <source file>")
        return
    }

    let file_path = args[1]

    let file = @fs.read_file_to_string?(file_path);
    if file.is_err() {
        println("Error reading file: \{file_path}")
        return
    }
    println("Reading source code from \{file_path}")
    
    let source = file.unwrap()
    let scanner = @lib.Scanner::new(source)
    let tokens = scanner.scan_tokens()

    match @lib.errorCount {
        { val: 0 } => println("Scanning completed successfully.\n")
        { val: total } => println("\{total} errors found during scanning.\n")
    }

    for tokenIdx, token in tokens {
        println("\{tokenIdx}: \{token}")
    }

    println("\nTotal tokens: \{tokens.length()}")
}
