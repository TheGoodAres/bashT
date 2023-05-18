#!/bin/bash

# Function to read the CSV file
read_csv_file() {
    filename=$1
    if [ -f "$filename" ]; then
        echo "=== Content of $filename ==="
        cat "$filename"
    else
        echo "File $filename does not exist."
    fi
}

# Function to edit the CSV file
edit_csv_file() {
    filename=$1
    if [ -f "$filename" ]; then
        echo "Opening $filename for editing..."
        nano "$filename"
    else
        echo "File $filename does not exist."
    fi
}

# Function to append content to the CSV file
append_to_csv_file() {
    filename=$1
    read -p "Enter nume: " nume
    read -p "Enter notaSO: " notaSO
    read -p "Enter email: " email

    if [ -f "$filename" ]; then
        # Get the last ID from the CSV file
        last_id=$(tail -1 "$filename" | cut -d',' -f1)
        new_id=$((last_id + 1))

        echo "$new_id,$nume,$notaSO,$email" >> "$filename"
        echo "Content appended to $filename"
    else
        echo "File $filename does not exist."
    fi
}

delete_entry_by_id() {
    filename=$1
    read -p "Enter id:" id

    grep -v -w "$id" "$filename" > temp.txt && mv temp.txt "$filename"
}
# Main loop
while true; do
    echo "CSV File Editor"
    echo "1. Read CSV file"
    echo "2. Edit CSV file"
    echo "3. Append content to CSV file"
    echo "4. Delete entry of CSV file"
    echo "0. Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            read -p "Enter the filename: " filename
            read_csv_file "$filename"
            ;;
        2)
            read -p "Enter the filename: " filename
            edit_csv_file "$filename"
            ;;
        3)
            read -p "Enter the filename: " filename
            append_to_csv_file "$filename"
            ;;
        4)
            read -p "Enter the filename: " filename
            delete_entry_by_id "$filename"
            ;;
        0)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice."
            ;;
    esac
done