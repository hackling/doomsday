package main

import "fmt"
import "time"
import "github.com/jinzhu/now"
import "math"

func main() {
	today := now.BeginningOfDay()
	delta := doomsday().Sub(today)
	puts := fmt.Printf

	puts("Days until Doomsday: %d \n", int(delta.Hours()/24))
	puts("Weekdays until Doomsday: %d \n", weekdayCount(today, doomsday()))
}

func doomsday() time.Time {
	doomsday, _ := time.Parse(
		time.RFC3339,
		"2018-03-29T00:00:00+10:00")

	return doomsday
}

func weekdayCount(now time.Time, date time.Time) int {
	switch {
	case now == date:
		return weekday(date)
	default:
		return weekday(date) + weekdayCount(now, date.Add(-24*time.Hour))
	}
}

func weekday(date time.Time) int {
	switch {
	case date.Weekday() == 0:
		return 0
	case date.Weekday() == 6:
		return 0
	default:
		return 1
	}
}
