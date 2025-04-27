# Make the script executable
```bash
chmod +x mygrep.sh
```

# How the script works
```bash
./mygrep.sh --help
Usage: ./mygrep.sh [-n] [-v] search_string filename
Options:
  -n  Show line numbers
  -v  Invert match (show non-matching lines)
  --help Show this help message
```

# Run the script with different options
```bash
./mygrep.sh hello testfile.txt
```
```bash
./mygrep.sh -n hello testfile.txt
```

```bash
./mygrep.sh -vn hello testfile.txt
```

```bash
./mygrep.sh -v testfile.txt
```

# 🧠 Reflective Section / Ask Questions
## how your script handles arguments and options.
The script first checks if any arguments are provided; if none, it displays a usage message and exits.
It manually parses all command-line options that start with a dash (-).
If options are combined (like -vn or -nv), the script loops through each character (v, n) and sets flags (invert_match and show_line_numbers) accordingly.

## If you were to support regex or -i/-c/-l options, how would your structure change?
The structure wouldn’t change much. I would just introduce two or three new variables like ignore_case, count_only, and list_filenames. Then, I would adjust the logic slightly when matching and printing results. Regex is already partly supported via Bash’s [[ =~ ]], so no major changes would be needed.

## What part of the script was hardest to implement and why?
The hardest parts were handling combined options like -vn and making the search case-insensitive.
Parsing each character of combined options manually was tricky to get right without breaking the argument flow.
Also, converting both the search string and each line to lowercase using tr added extra steps to the matching logic, making it slightly more complex.