package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"os"
	"sort"
	"strings"
	"time"
)

// Schedule holds data about one rotation.
type Schedule struct {
	Title     string   `json:"title"`
	Periods   []string `json:"periods"`
	Times     []string `json:"times"`
	Dismissal string   `json:"dismissal"`
}

// ScheduleMap maps rotation (A,B,C,...) to Schedule
type ScheduleMap map[string]Schedule

// Event is eventual structure (array of events) returned, ordered by date.
type Event struct {
	Date      string   `json:"date"`
	Title     string   `json:"title"`
	Periods   []string `json:"periods"`
	Times     []string `json:"times"`
	Dismissal string   `json:"dismissal"`
	summary   string
}

func main() {

	var rotations ScheduleMap
	if err := json.Unmarshal(rotationLogic, &rotations); err != nil {
		panic(err)
	}

	var emptyArray = make([]string, 0)
	events := parseCal()
	for i, event := range events {

		if len(event.summary) == 0 {
			// fill in empty events (holidays/weekends) with empty arrays,
			// so JSON marshaller doesn't output "null" value
			events[i].Periods = emptyArray
			events[i].Times = emptyArray
			continue
		}

		summary := event.summary

		var schedule Schedule
		var ok bool
		if len(summary) == 1 {
			schedule, ok = rotations[summary]
		} else if isTesting(summary) {
			schedule, ok = rotations["TEST"]
		} else if isFull(summary) {
			schedule, ok = rotations["FULL"]
		} else if isSchoolClosed(summary) {
			continue
		} else {
			schedule, ok = customSchedule(summary)
		}

		if ok {
			events[i].Title = schedule.Title
			events[i].Periods = schedule.Periods
			events[i].Times = schedule.Times
			events[i].Dismissal = schedule.Dismissal
		} else {
			panic(fmt.Errorf("Can't create event for summary: %s", summary))
		}
	}

	data, err := json.Marshal(events)
	if err != nil {
		panic(err)
	}
	fmt.Println(string(data))
}

func isSchoolClosed(summary string) bool {
	str := strings.ToUpper(summary)
	return strings.HasPrefix(str, "SCHOOL CLOSED")
}

func isTesting(summary string) bool {
	str := strings.ToUpper(summary)
	return strings.Contains(str, "TESTING")
}

func isFull(summary string) bool {
	str := strings.ToUpper(summary)
	return strings.Contains(str, "FULL") || strings.Contains(str, "SPECIAL")
}

// Parse summaries like "*2-MASS-4-6" into custom schedules
func customSchedule(summary string) (Schedule, bool) {

	var str string
	for _, s := range strings.Split(strings.ToUpper(summary), "|") {
		if s[0:1] == "*" {
			str = s
		}
	}

	if str == "" {
		return Schedule{}, false
	}

	var periods []string

	if strings.HasPrefix(str, "*LATE START") {
		periods = strings.Split(str[12:], "-")
	} else {
		periods = strings.Split(str[1:], "-")
	}

	for i, p := range periods {
		if p == "MASS" {
			periods[i] = "M"
		} else if p == "CD" { // Career Day
			periods[i] = "C"
		}
	}

	var sch = Schedule{}

	// lunch index depends on number of periods
	var lunch int
	n := len(periods)
	if n == 3 {
		lunch = 1
		sch.Title = "Late Start"
		sch.Times = []string{"9:35am", "11:05am", "11:40am", "1:15pm"}
		sch.Dismissal = "2:40pm"
	} else if n == 4 {
		lunch = 2
		sch.Title = "Mass/Assembly"
		sch.Times = []string{"8:00am", "9:35am", "11:05am", "11:40am", "1:15pm"}
		if periods[n-1] == "X" {
			sch.Dismissal = "1:45pm"
		} else {
			sch.Dismissal = "2:40pm"
		}
	} else {
		panic(fmt.Errorf("Can't create custom schedule for %s", str))
	}

	// Go doesn't make it easy to insert an element into a slice...
	periods = append(periods, "")
	copy(periods[lunch+1:], periods[lunch:])
	periods[lunch] = "L"

	// finish out filling in the custom schedule
	sch.Periods = periods

	return sch, true
}

// parseCal retrieves all events out a calendar, appending elements that
// share the same date into the summary array.  The array of events returned
// is continuous -- all missing dates between the first and last dates
// are fill in.
func parseCal() []Event {

	const (
		veventBegin   = "BEGIN:VEVENT"
		veventEnd     = "END:VEVENT"
		veventDTStart = "DTSTART;VALUE=DATE:"
		veventSummary = "SUMMARY:"
	)

	var (
		dtstart   string
		summary   string
		startDate string
		endDate   string
	)

	// map[YMD] = summary1|summary2
	eventMap := make(map[string]string)

	// read ICS calendar from STDIN
	scanner := bufio.NewScanner(os.Stdin)

	for scanner.Scan() {
		line := scanner.Text()

		if line == veventBegin {
			dtstart = ""
			summary = ""
		} else if strings.HasPrefix(line, veventDTStart) {
			dtstart = line[len(veventDTStart):]
			if startDate == "" {
				startDate = dtstart
			}
		} else if strings.HasPrefix(line, veventSummary) {
			summary = line[len(veventSummary):]
		} else if line == veventEnd {
			if sums, ok := eventMap[dtstart]; ok {
				eventMap[dtstart] = fmt.Sprintf("%s|%s", sums, summary)
			} else {
				eventMap[dtstart] = summary
			}
		}
	}

	endDate = dtstart

	// convert startDate into Time
	current, err := time.Parse("20060102", startDate)
	if err != nil {
		panic(err)
	}

	// fill in all missing days between startDate and endDate
	for {
		current = current.AddDate(0, 0, 1) // add 1 day
		d := current.Format("20060102")    // format into "yyyymmdd" string
		if d == endDate {
			break
		}

		// if day doesn't exist (weekends and holidays), fill it in
		if _, ok := eventMap[d]; !ok {
			eventMap[d] = ""
		}
	}

	// convert map into ordered Event array

	// 1. sort the keys
	numEvents := len(eventMap)
	keys := make([]string, numEvents)
	i := 0
	for k := range eventMap {
		keys[i] = k
		i++
	}
	sort.Strings(keys)

	events := make([]Event, numEvents)
	for i := 0; i < numEvents; i++ {
		ymd := keys[i]
		events[i] = Event{Date: ymd, summary: eventMap[ymd]}
	}

	return events
}

var rotationLogic = []byte(`{
	"A": {
		"title": "Regular Schedule (A)",
		"periods": ["1", "3", "L", "5", "7"],
		"times": ["8:00am", "9:35am", "11:05am", "11:40am", "1:15pm"],
		"dismissal": "2:40pm"
	},
	"B": {
		"title": "Regular Schedule (B)",
		"periods": ["2", "4", "L", "6", "X"],
		"times": ["8:00am", "9:35am", "11:05am", "11:40am", "1:15pm"],
		"dismissal": "1:40pm"
	},
	"C": {
		"title": "Regular Schedule (C)",
		"periods": ["3", "5", "L", "7", "1"],
		"times": ["8:00am", "9:35am", "11:05am", "11:40am", "1:15pm"],
		"dismissal": "2:40pm"
	},
	"D": {
		"title": "Regular Schedule (D)",
		"periods": ["4", "6", "L", "2", "X"],
		"times": ["8:00am", "9:35am", "11:05am", "11:40am", "1:15pm"],
		"dismissal": "1:40pm"
	},
	"E": {
		"title": "Regular Schedule (E)",
		"periods": ["5", "7", "L", "1", "3"],
		"times": ["8:00am", "9:35am", "11:05am", "11:40am", "1:15pm"],
		"dismissal": "2:40pm"
	},
	"F": {
		"title": "Regular Schedule (F)",
		"periods": ["6", "2", "L", "4", "X"],
		"times": ["8:00am", "9:35am", "11:05am", "11:40am", "1:15pm"],
		"dismissal": "1:40pm"
	},
	"G": {
		"title": "Regular Schedule (G)",
		"periods": ["7", "1", "L", "3", "5"],
		"times": ["8:00am", "9:35am", "11:05am", "11:40am", "1:15pm"],
		"dismissal": "2:40pm"
	},
	"H": {
		"title": "Late Start (H)",
		"periods": ["2", "L", "4", "6"],
		"times": ["9:35am", "11:05am", "11:40am", "1:15pm"],
		"dismissal": "2:40pm"
	},
	"FULL": {
		"title": "Full Schedule",
	    "periods": ["1", "2", "3", "4", "L", "5", "6", "7"],
	    "times": ["8:00m", "8:52am", "9:54am", "10:46am", "11:33am", "12:08pm", "1:00pm", "1:52pm"],
	    "dismissal": "2:40pm"
	},
	"MASS": {
		"title": "Mass/Assembly",
	    "periods":  ["1", "M", "L", "2", "3"],
    	"times": ["8:00am", "9:35am", "11:05am", "11:40am", "1:15pm"],
    	"dismissal": "2:40pm"
	},
	"TEST": {
		"title": "Testing Day",
		"periods": ["T"],
		"times": ["8:00am"],
		"dismissal": "12:00pm"
	}
}`)
