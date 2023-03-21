use std::env;
use std::fs::File;
use std::io::{BufReader, BufWriter};

const PKG_NAME: &str = env!("CARGO_PKG_NAME");
const PKG_VERSION: &str = env!("CARGO_PKG_VERSION");

fn main() {
    println!("{PKG_NAME} {PKG_VERSION}");

    let args: Vec<String> = env::args().collect();
    let context_file = args.get(1).expect("No context file provided");
    let file = File::open(context_file).expect("Opening context file");
    let mut context = java_properties::read(BufReader::new(file)).expect("Reading context file");

    env::vars()
        .filter(|(key, _)| key.starts_with("CONTEXT_"))
        .for_each(|(key, value)| {
            let property_name = key.strip_prefix("CONTEXT_").expect("Stripping prefix");
            println!("Overriding {property_name}");
            context.insert(property_name.to_string(), value);
        });

    let file = File::create(context_file).expect("Opening context file");
    java_properties::write(BufWriter::new(file), &context).expect("Writing context file");
}
