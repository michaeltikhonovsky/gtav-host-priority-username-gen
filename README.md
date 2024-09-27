# Hash Finder

This project includes two implementations of a hash finding program - one in C and one in Zig. Both programs perform the same function: they generate strings and calculate their Jenkins hash, printing out those that meet a certain threshold. The strings with low hash values can be used in Grand Theft Auto V (GTA V) to gain higher priority for becoming the host of a multiplayer lobby.

## Features

- Two implementation options: C and Zig
- Custom or random string generation
- Jenkins hash calculation
- Progress tracking for long runs

## How it works

1. The user chooses between two formatting options:

   - Custom format (000_name_000)
   - Complete random format

2. The program generates strings based on the chosen format.

3. For each generated string, it calculates the Jenkins hash.

4. If the hash is below a certain threshold (defined as HASH_THRESHOLD), the program prints the hash and the corresponding string.

5. The program continues to generate and check strings indefinitely, or until manually stopped.

## Usage

### C Version

Compile the C program:

```
gcc hash.c -O3 -o hash
```

Run the compiled program:

```
./hash
```

### Zig Version

Compile the the Zig program:

```
zig build-exe hash.zig -O ReleaseFast
```

Run the compiled program:

```
zig run hash.o
```

## Configuration

Both versions use the following constants that can be adjusted in the source code:

- `MAX_NAME_LENGTH`: Maximum length of generated names (default: 16)
- `HASH_THRESHOLD`: Threshold for printing hashes (default: 5)
- `MAX_MIDDLE_LENGTH`: Maximum length of the middle part in custom format (default: 8)

## Performance

Both implementations are optimized for performance, using inline functions and efficient string manipulation techniques. The Zig version may have slightly different performance characteristics due to language-specific optimizations.

## Notes

- The programs will run indefinitely until manually stopped (e.g., with Ctrl+C).
- Progress is reported every 100 million names generated.
- If option 1 (Custom format) is chosen, the generated usernames will begin to loop after approximately 2 billion iterations. This behavior is consistent for all custom-generated names, regardless of the specific string used in the middle.
  - The loop occurs because the program exhausts all possible combinations for the 3-character prefix and suffix (36^3 \* 36^3 = 2,176,782,336 combinations).
  - After reaching the end of these combinations, the program starts over from the beginning.
- For option 2 (Complete random format):
  - The looping behavior is likely not present in option 2, since the entire string is randomized.
  - Looping behavior depends on the chosen length of the random string.
  - Shorter lengths will result in earlier looping due to fewer possible combinations.
  - The time to complete a loop or exhaust all possibilities increases exponentially with the length of the generated string.
