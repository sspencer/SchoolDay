# Parse ICS Calendar

The go code here reads in a calendar file from <stdin> and outputs a JSON events
calendar.

    cat ../rotation.ics go run main.go > ../rotation.json
