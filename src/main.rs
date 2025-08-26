fn main() {
    println!("Hello, World from Rust via Nix-Polyglot! 🦀");
    println!("This demonstrates the organizational infrastructure approach.");

    // Print build mode information
    #[cfg(debug_assertions)]
    println!("🔧 Running DEBUG build (dev mode)");

    #[cfg(not(debug_assertions))]
    println!("🚀 Running RELEASE build (optimized)");

    // Simple loop to show it actually works
    for i in 0..5 {
        println!("Count: {}", i);
    }
}

pub fn add(a: i32, b: i32) -> i32 {
    a + b
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_add() {
        assert_eq!(add(2, 3), 5);
        assert_eq!(add(-1, 1), 0);
        assert_eq!(add(0, 0), 0);
    }

    #[test]
    fn test_add_negative() {
        assert_eq!(add(-2, -3), -5);
        assert_eq!(add(-10, 5), -5);
    }
}
