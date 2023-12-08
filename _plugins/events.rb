require "icalendar"
require "digest"
require "time"
require "tzinfo"
require "icalendar/tzinfo"

module Jekyll
  class QTiesEventGenerator < Jekyll::Generator
    def generate(site)
      @tzid = "Europe/Berlin"
      @time_zone = TZInfo::Timezone.get(@tzid)
      ics = PageWithoutAFile.new(site, __dir__, "", "events.ics")
      ics.content = calendar(site.config["url"], site.collections["events"].docs)
      ics.data["layout"] = nil
      site.pages << ics
    end

    private def date_with_time(date, time)
      ENV["TZ"] = @tzid
      Time.strptime("#{date} #{time}", "%Y-%m-%d %H:%M")
    end

    private def calendar(site_url, events)
      cal = Icalendar::Calendar.new
      cal.add_timezone(@time_zone.ical_timezone(DateTime.new 2022, 1, 1, 0, 0, 0))

      events.each do |event|
        event.data["dates"].each do |date|
          e = cal.event
          long_id = "#{date["day"]}-#{event.id}"
          e.uid = Digest::SHA2.hexdigest long_id
          e.summary = event.data["title"]
          url = site_url + event.url
          e.url = url
          e.description = "#{event.data["description"]}\nAlle Details auf #{url}"
          e.ip_class = "PUBLIC"
          e.organizer = "mailto:info@qties-muenchen.de"
          e.location = event.data["place"] || date["place"]

          start_time = date_with_time(date["day"], date["start"])
          end_time = date_with_time(date["day"], date["end"])

          e.dtstart = Icalendar::Values::DateTime.new start_time, 'tzid' => @tzid
          e.dtend = Icalendar::Values::DateTime.new end_time, 'tzid' => @tzid
        end
      end
      cal.publish
      cal.to_ical
    end
  end
end
