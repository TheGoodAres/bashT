#!/bin/bash

# Function to read the CSV file
read_csv_file() {
    read -r -p "Enter the filename or exit: " filename
    #if the file exista then its contents will be printed on the screen
    filename=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
    if [[ $filename == "exit" ]]; then
        echo "Exiting reading mode"
    elif [ -f "$filename" ]; then
        echo "=== Content of $filename ==="
        cat "$filename"
    else
        echo "File $filename does not exist."
    fi
}

# Function to append content to the CSV file
append_to_csv_file() {
    read -r -p "Enter the filename or exit: " filename
    #the following checks if the given file exists, if it does not then it will let the user know
    filename=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
    if [[ $filename == "exit" ]]; then
        echo "Exiting appending mode"
    elif [ -f "$filename" ]; then
    #regex used to match a basic email
        regex="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
        read -r -p "Enter nume: " nume
        #the following will ensure that the input is between 1 and 10,
        #it will loop until the input matches the requirements
        while true; do 
            read -r -p "Enter notaSO: " notaSO
            if [[ "$notaSO" =~ ^[1-9]$ ]] || [[ "$notaSO" == 10 ]]; then
                break
            else 
                echo "Invalid number. Please enter a number between 1 and 10"
            fi
        done
        #the following will run until the input matches the regex set further up
        while true; do
            read -r -p "Enter email: " email
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

# Function to delete a row by its id
delete_entry_by_id() {
    read -r -p "Enter the filename or exit: " filename
    filename=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
    if [[ $filename == "exit" ]]; then
        echo "Exiting deleting mode"
    #checks that the file exists
    elif [ -f "$filename" ]; then
        #print the file
        cat "$filename"
        #take the user input
        read -r -p "Enter id:" id
        #find the line that with the id that matches, write the rest of the lines in a temporary file and then rename it to the given filename
        grep -v -w "$id" "$filename" > temp.txt && mv temp.txt "$filename"
    else 
        echo "File $filename does not exits."
    fi
}
#function to edit a row by its id
edit_row() {
    read -r -p "Enter the filename or exit: " filename
    filename=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
    if [[ $filename == "exit" ]]; then
        echo "Exiting editing mode"
    #checks if the file exists
    elif [ -f "$filename" ]; then
        #print the file
        cat "$filename"
        #basic regex for email
        regex="^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"
        read -r -p "Enter id: " id
        read -r -p "Enter name: " name
        #checks if the input is between 1 and 10, if it does not match, it will ask until it does
        while true; do 
            read -r -p "Enter notaSO: " notaSO
            if [[ "$notaSO" =~ ^[1-9]$ ]] || [[ "$notaSO" == 10 ]]; then
                break
            else 
                echo "Invalid number. Please enter a number between 1 and 10"
            fi
        done
        #checks that the input matches the regex for the email, if it does not it will ask until it does
        while true; do
            read -r -p "Enter email: " email
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

#function to show the top 4 notaSO
sort_by_notaSO() {
    read -r -p "Enter the filename or exit: " filename
    filename=$(echo "$filename" | tr '[:upper:]' '[:lower:]')
    if [[ $filename == "exit" ]]; then
        echo "Exiting sorting mode"
    #check if the file exists
    elif [ -f "$filename" ]; then
        #sorts the file by using the delimiter ",", then sets the sorting parameter to the 3rd column
        #tells it that it is a numerical variable
        #makes it sort it as  reverse
        #then displays the first 4 lines of the file
        sort -t ',' -k3,3nr "$filename" | head -n 4
    else
        echo "File $filename does not exist."
    fi
}

#function to create a new csv fiile
create_csv_file() {
    while true; do
        read -r -p "Enter the filename(without extension) or 'exit': " filename
        #checks if the file exists
        if [ -f "$filename" ]; then 
            echo "This file already exists!"
        #checks if the input contsins ".csv"
        elif [[ $filename == *".csv"* ]]; then
            echo "Do not add the file extensio."
        #checks if the input is "exit", it will stop the loop if it is so
        elif [[ $filename == "exit" ]]; then
            echo "Exiting creating mode."
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
    read -r -p "Enter your choice: " choice

    case $choice in
        1)
            read_csv_file 
            ;;
        2)
            create_csv_file 
            ;;
        3)
            
            edit_row 
            ;;
        4)
            append_to_csv_file
            ;;
        5)
            delete_entry_by_id 
            ;;
        6)
            sort_by_notaSO 
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