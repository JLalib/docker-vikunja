#!/bin/bash

CONTAINER="vikunja"
BIN="/app/vikunja/vikunja"
LINE="------------------------------------------"

vk() {
    docker exec -i "$CONTAINER" "$BIN" "$@"
}

list_users() {
    echo "$LINE"
    echo -e "\e[0;32mUser list:\e[00m"
    vk user list
}

create_user() {
    read -rp "Enter the username: " username
    read -rsp "Enter the password: " password
    echo
    read -rp "Enter the email address: " email

    vk user create -e "$email" -p "$password" -u "$username"
}

delete_user() {
    list_users
    read -rp "Enter the ID of the user you want to delete: " userID

    # Con -c -n borra directamente, sin confirmación
    vk user delete "$userID" -c -n
}

main() {
    while true; do
        echo "$LINE"
        echo -e "\e[0;32mWhat action would you like to perform?\e[00m"
        echo "1. List users"
        echo "2. Create user"
        echo "3. Delete user"
        echo "4. Exit"
        echo "$LINE"

        read -rp "Enter the number of the action you want to perform: " option

        case $option in
            1) list_users ;;
            2) create_user ;;
            3) delete_user ;;
            4) echo -e "\e[0;32mExiting.\e[00m"; exit 0 ;;
            *) echo "Invalid option. Please select a valid option." ;;
        esac
    done
}

main
