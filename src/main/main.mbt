let hasError: Ref[Bool] = { val: false }

fn main {
    let args = @env.args()
    println(args)
    if args.length() != 2 {
        println("Usage: moon run <source file>")
        return
    }

    let file_path = args[1]

    let file= @fs.read_file_to_string?(file_path);
    if file.is_err() {
        println("Error reading file: \{file_path}")
        return
    }
    println("Reading source code from \{file_path}")
    
    let source = file.unwrap();
    println(source);
}

fn error(line: Int, message: String) -> Unit {
    report(line, "", message)
}

fn report(line: Int, location: String, message: String) -> Unit {
    println("[line \{line}] Error \{location}: \{message}")
}
