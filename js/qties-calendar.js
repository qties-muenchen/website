const calendarDom = document.getElementById("qties-calendar");
const calendar = new FullCalendar.Calendar(calendarDom, {
  locale: "de",
  firstDay: 1,
  events: {
    url: "/events.ics",
    format: "ics"
  },
  eventClick: info => {
    info.jsEvent.preventDefault();

    if (info.event.url) {
      window.open(info.event.url);
    }
  }
});
calendar.render();
