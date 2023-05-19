#!/bin/bash

# Function to read the CSV file
read_csv_file() {
    filename=$1
    #if the file exista then its contents will be printed on the screen
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
    #the following checks if the given file exists, if it does not then it will let the user know
    if [ -f "$filename" ]; then
    #regex used to match a basic email
        regex="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
        read -p "Enter nume: " nume
        #the following will ensure that the input is between 1 and 10,
        #it will loop until the input matches the requirements
        while true; do 
            read -p "Enter notaSO: " notaSO
            if [[ "$notaSO" =~ ^[1-9]$ ]] || [[ "$notaSO" == 10 ]]; then
                break
            else 
                echo "Invalid number. Please enter a number between 1 and 10"
            fi
        done
        #the following will run until the input matches the regex set further up
        while true; do
            read -p "Enter email: " email
            if [[ $email =~ $regex ]]; then
                break
            else 
                echo "Invalid email. Please try again!"
            fi
        done
        # Get the last ID from the CSV file and add 1 to it
        last_id=$(tail -1 "$filename" | cut -d',' -f1)
        new_id=$((last_id + 1))
        #append  new_id, nume,notsSO and email in the file separated by "," with a starts a new line after appending it
        echo "$new_id,$nume,$notaSO,$email" >> "$filename"
        echo "Content appended to $filename"
    else
        echo "File $filename does not exist."
    fi
}

delete_entry_by_id() {
    filename=$1
    #checks that the file exists
    if [ -f "$filename" ]; then
        #print the file
        cat "$filename"
        #take the user input
        read -p "Enter id:" id
        #find the line that with the id that matches, write the rest of the lines in a temporary file and then rename it to the given filename
        grep -v -w "$id" "$filename" > temp.txt && mv temp.txt "$filename"
    else 
        echo "File $filename does not exits."
    fi
}
edit_row() {
    filename=$1
    #checks if the file exists
    if [ -f "$filename" ]; then
        #print the file
        cat "$filename"
        #basic regex for email
        regex="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
        read -p "Enter id: " id
        read -p "Enter name: " name
        #checks if the input is between 1 and 10, if it does not match, it will ask until it does
        while true; do 
            read -p "Enter notaSO: " notaSO
            if [[ "$notaSO" =~ ^[1-9]$ ]] || [[ "$notaSO" == 10 ]]; then
                break
            else 
                echo "Invalid number. Please enter a number between 1 and 10"
            fi
        done
        #checks that the input matches the regex for the email, if it does not it will ask until it does
        while true; do
            read -p "Enter email: " email
            if [[ $email =~ $regex ]]; then
                break
            else 
                echo "Invalid email. Please try again!"
            fi
        done
        #create a string with all the information for the edited row
        local new_row="$id,$name,$notaSO,$email"
        #create temporary file
        local temp_file=$(mktemp)
        #run through the file until the id matches the id introduced by the  user, it will write the rows that do not match and when the 
        #row that matches is found, the prepared row (new_row) will be written.
        #this will be stored in a temporary file and the renamed into the file given by the user
        awk -v id="$id" -v row="$new_row" 'BEGIN{FS=OFS=","} $1 != id {print $0} $1 == id {print row}' "$filename" > "$temp_file" && mv "$temp_file" "$filename"
    else 
        echo "File $filename does not exist."
    fi
}

sort_by_notaSO() {
    filename=$1
    #check if the file exists
    if [ -f "$filename" ]; then
        #sorts the file by using the delimiter ",", then sets the sorting parameter to the 3rd column
        #tells it that it is a numerical variable
        #makes it sort it as  reverse
        #then displays the first 4 lines of the file
        sort -t ',' -k3,3nr "$filename" | head -n 4
    else
        echo "File $filename does not exist."
    fi
}

create_csv_file() {
    while true; do
        read -p "Enter the filename(without extension) or "exit": " filename
        #checks if the file exists
        if [ -f "$filename" ]; then 
            echo "This file already exists!"
        #checks if the input contsins ".csv"
        elif [[ $filename == *".csv"* ]]; then
            echo "Do not add the file extensio."
        #checks if the input is "exit", it will stop the loop if it is so
        elif [[ $filename == "exit" ]]; then
            echo "Exiting."
            break
        else
            echo "ID,Nume,NotaSO,email" > "$filename.csv"
            break
        fi
    done
}
# Main loop
while true; do
    echo "------------------------------------------------------------------"
    echo "CSV File Editor"
    echo "1. Read CSV file"
    echo "2. Create CSV file"
    echo "3. Edit CSV row by id"
    echo "4. Append content to CSV file"
    echo "5. Delete entry of CSV file"
    echo "6. Sort by notaSO"
    echo "0. Exit"
    echo "------------------------------------------------------------------"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            read -p "Enter the filename: " filename
            read_csv_file "$filename"
            ;;
        2)
            create_csv_file "$filename"
            ;;
        3)
            read -p "Enter the filename: " filename
            edit_row "$filename"
            ;;
        4)
            read -p "Enter the filename: " filename
            append_to_csv_file "$filename"
            ;;
        5)
            read -p "Enter the filename: " filename
            delete_entry_by_id "$filename"
            ;;
        6)
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