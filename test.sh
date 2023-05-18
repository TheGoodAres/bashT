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

# Function to append content to the CSV file
append_to_csv_file() {
    filename=$1
    regex="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
    read -p "Enter nume: " nume
    while true; do 
        read -p "Enter notaSO: " notaSO
        if [[ "$notaSO" =~ ^[1-9]$ ]] || [[ "$notaSO" == 10 ]]; then
            break
        else 
            echo "Invalid number. Please enter a number between 1 and 10"
        fi
    done
    while true; do
        read -p "Enter email: " email
        if [[ $email =~ $regex ]]; then
            break
        else 
            echo "Invalid email. Please try again!"
        fi
    done
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
    if [ -f "$filename" ]; then
        grep -v -w "$id" "$filename" > temp.txt && mv temp.txt "$filename"
    else 
        echo "File $filename does not exits."
    fi
}
edit_row() {
    filename=$1
    if [ -f "$filename" ]; then
        regex="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
        read -p "Enter id: " id
        read -p "Enter name: " name
        while true; do 
            read -p "Enter notaSO: " notaSO
            if [[ "$notaSO" =~ ^[1-9]$ ]] || [[ "$notaSO" == 10 ]]; then
                break
            else 
                echo "Invalid number. Please enter a number between 1 and 10"
            fi
        done
        while true; do
            read -p "Enter email: " email
            if [[ $email =~ $regex ]]; then
                break
            else 
                echo "Invalid email. Please try again!"
            fi
        done
        local new_row="$id,$name,$notaSO,$email"
        local temp_file=$(mktemp)

        awk -v id="$id" -v row="$new_row" 'BEGIN{FS=OFS=","} $1 != id {print $0} $1 == id {print row}' "$filename" > "$temp_file" && mv "$temp_file" "$filename"
    else 
        echo "File $filename does not exist."
    fi
}

sort_by_notaSO() {
    filename=$1
    if [ -f "$filename" ]; then
        sort -t ',' -k3,3nr "$filename" | head -n 4
    else
        echo "File $filename does not exist."
    fi
}
# Main loop
while true; do
    echo "CSV File Editor"
    echo "1. Read CSV file"
    echo "2. Edit CSV row by id"
    echo "3. Append content to CSV file"
    echo "4. Delete entry of CSV file"
    echo "5. Sort by notaSO"
    echo "0. Exit"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            read -p "Enter the filename: " filename
            read_csv_file "$filename"
            ;;
        2)
            read -p "Enter the filename: " filename
            edit_row "$filename"
            ;;
        3)
            read -p "Enter the filename: " filename
            append_to_csv_file "$filename"
            ;;
        4)
            read -p "Enter the filename: " filename
            delete_entry_by_id "$filename"
            ;;
        5)
            read -p "Enter the filename: " filename
            sort_by_notaSO "$filename"
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