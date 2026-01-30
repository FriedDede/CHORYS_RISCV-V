import argparse

# Define the global variable CLINT_FREQ
CLINT_FREQ = 25 * 10**6  # 50 x 10^6 or 50,000,000

# Function to compute the mean of a list of numbers
def compute_mean(numbers):
    return sum(numbers) / len(numbers)

# Function to process the input and output files
def process_files(input_file, output_file):
    # Open the input file for reading and the output file for writing results
    with open(input_file, "r") as infile, open(output_file, "w") as outfile:
        # Initialize variables to store name and hex numbers
        name = None
        hex_numbers = []
        
        for line in infile:
            # Strip whitespace and newline characters
            line = line.strip()
            
            # Check if the line starts with "Processing:"
            if line.startswith("Processing:"):
                # If we already have a name and hex numbers, process them
                if name and hex_numbers:
                    # Compute the mean of the hex numbers (in decimal)
                    mean_value = compute_mean(hex_numbers)
                    
                    # Divide the mean by CLINT_FREQ
                    adjusted_mean = mean_value / CLINT_FREQ
                    
                    # Write the name and adjusted mean to the output file
                    outfile.write(f"{name}: {adjusted_mean:.6f}\n")
                
                # Start a new group
                name = line.split("Processing: ")[1]
                hex_numbers = []
            
            # Check if the line is a hex number (if it’s not a separator)
            elif line and line != "-":
                try:
                    # Convert the hex string to an integer and add to the list
                    hex_number = int(line, 16)
                    hex_numbers.append(hex_number)
                except ValueError:
                    print(f"Invalid hex number: {line}")
            
            # When encountering the separator, process the current group
            elif line == "-":
                # If there are hex numbers to process, compute the mean
                if name and hex_numbers:
                    mean_value = compute_mean(hex_numbers)
                    
                    # Divide the mean by CLINT_FREQ
                    adjusted_mean = mean_value / CLINT_FREQ
                    
                    # Write the name and adjusted mean to the output file
                    outfile.write(f"{name}: {adjusted_mean:.6f}\n")
                    
                # Reset for the next group
                name = None
                hex_numbers = []
        
        # Handle the last group if it hasn't been processed yet
        if name and hex_numbers:
            mean_value = compute_mean(hex_numbers)
            adjusted_mean = mean_value / CLINT_FREQ
            outfile.write(f"{name}: {adjusted_mean:.6f}\n")

# Main function to handle arguments
def main():
    # Set up argument parsing
    parser = argparse.ArgumentParser(description="Process hex numbers from a file and compute adjusted means.")
    
    # Add input_file and output_file arguments
    parser.add_argument("input_file", help="The input file containing the hex numbers.")
    parser.add_argument("output_file", help="The output file to write the results.")
    
    # Parse the arguments
    args = parser.parse_args()
    
    # Call the process_files function with the input and output files
    process_files(args.input_file, args.output_file)

if __name__ == "__main__":
    main()
