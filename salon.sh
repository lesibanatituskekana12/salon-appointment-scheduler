#!/bin/bash

# Function to display the list of services
display_services() {
    echo "Welcome to the Salon! Here are our services:"
    SERVICES=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT service_id, name FROM services ORDER BY service_id")
    echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME; do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done
}

# Display services when the script starts
display_services

# Loop until the user selects a valid service
while true; do
    echo -e "\nPlease select a service by entering the service ID:"
    read SERVICE_ID_SELECTED
    
    # Check if the service ID is valid
    SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    
    if [[ -z $SERVICE_NAME ]]; then
        # If the service is invalid, display the list of services again
        echo "Invalid service ID. Please try again."
        display_services
    else
        # If the service is valid, break out of the loop
        break
    fi
done

# Ask for customer phone number
echo -e "\nEnter your phone number:"
read CUSTOMER_PHONE

# Check if the customer exists
CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]; then
    # If the customer doesn't exist, prompt for name and add to the database
    echo -e "\nIt seems you are a new customer. Please enter your name:"
    read CUSTOMER_NAME
    psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
fi

# Ask for appointment time
echo -e "\nEnter the time you'd like for your appointment (e.g., 2:30 PM):"
read SERVICE_TIME

# Get the customer_id
CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t --no-align -c "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

# Create the appointment
psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

# Confirmation message
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
