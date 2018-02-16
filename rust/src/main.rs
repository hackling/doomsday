extern crate chrono;
extern crate time;
extern crate colored;

use chrono::prelude::*;
use time::Duration;
use colored::*;

fn main() {
    let today: DateTime<Utc> = Utc::now();
    let doomsday: DateTime<Utc> = Utc.ymd(2018, 3, 29).and_hms(10,0,0);
    let days_left: i64 = duration(doomsday, today);

    println!("Days until Doomsday: {}", redify(days_left));
    println!("Weekdays until Doomsday: {}", redify(count_weekdays(days_left, today)));
}

fn redify(input: i64) -> colored::ColoredString { input.to_string().on_red().dimmed(); }

fn duration(x: DateTime<Utc>, y: DateTime<Utc>) -> i64 { x.signed_duration_since(y).num_days() }

fn count_weekdays(index: i64, date: DateTime<Utc>) -> i64 {
    match index {
        0 => weekday_incrementer(date),
        _ => weekday_incrementer(date) + count_weekdays(index - 1, date - Duration::days(1))
    }
}

fn weekday_incrementer(date: DateTime<Utc>) -> i64 {
    match date.weekday() {
        Weekday::Sun | Weekday::Sat => 0,
        _ => 1
    }
}


