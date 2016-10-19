package main

import (
	"bufio"
	"fmt"
	"os"
	"sort"
	"strings"
)

type Event struct {
	Date    string
	Summary []string
}

type EventMap map[string]string

func main() {
	events, err := parseCal()
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	fmt.Printf("%v\n", events)
}

func parseCal() ([]Event, error) {

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

	eventMap := make(map[string][]string)

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
				eventMap[dtstart] = append(sums, summary)
			} else {
				eventMap[dtstart] = []string{summary}
			}
		}
	}

	endDate = dtstart

	keys := make([]string, len(eventMap))
	i := 0
	for k, _ := range eventMap {
		keys[i] = k
		i++
	}
	sort.Strings(keys)
	for _, k := range keys {
		fmt.Println(eventMap[k])
	}

	fmt.Printf("Start: %s, End: %s\n", startDate, endDate)

	/*
			current, err := time.Parse("20060102", events[0].dtstart)
		    if err == nil {
		    	return err
		    }

		    last := len(events) - 1
		    endDate = events[last].dtstart
		    fmt
	*/

	return make([]Event, 1), nil

}
