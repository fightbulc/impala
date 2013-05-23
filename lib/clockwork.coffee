define (require) ->
  Imp = require('impala')
  AbstractManager = require('abstract-manager')

  ###############################################

  __private =
    moduleName: ->
      'manager.Clockwork'

  ###############################################

  class Clockwork extends AbstractManager
    _useUTC: false

    # -------------------------------------------

    _dddd: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
    _ddd: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
    _MMMM: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
    _MMM: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']

    # -------------------------------------------

    _tokens:
      'H': -> @hours()
      'HH': -> @_makeTwoDigits(@hours())
      'h': -> @hours() % 12
      'hh': -> @_makeTwoDigits(@hours() % 12)
      'm': -> @minutes()
      'mm': -> @_makeTwoDigits(@minutes())
      's': -> @seconds()
      'ss': -> @_makeTwoDigits(@seconds())
      'd': -> @day()
      'do': -> @_numerate(@day())
      'ddd': -> @_ddd[@day()]
      'dddd': -> @_dddd[@day()]
      'D': -> @date()
      'Do': -> @_numerate[@date()]
      'DD': -> @_makeTwoDigits(@date())
      'M': -> @month()
      'MM': -> @_makeTwoDigits(@month())
      'MMM': -> @_MMM(@month()-1)
      'MMMM': -> @_MMMM(@month()-1)
      'YY': -> @year() % 100
      'YYYY': -> @year()
      'a': -> if @hours() > 12 then 'pm' else 'am'
      'A': -> if @hours() > 12 then 'PM' else 'AM'

    # -------------------------------------------

    _relativeTime:
      future: "in %s"
      past: "%s ago"
      s: "secs"
      m: "a min"
      mm: "%d mins"
      h: "an hour"
      hh: "%d hrs"
      d: "a day"
      dd: "%d days"
      M: "a month"
      MM: "%d months"
      y: "a year"
      yy: "%d yrs"

    # -------------------------------------------

    _periods:
      minute: 60
      hour: 3600
      day: 24 * 3600
      month: 30 * 24 * 3600
      year: 365 * 30 * 24 * 3600

    # -------------------------------------------

    constructor: (timeString) ->
      timeString.replace(
        /^([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})([\+\-]{1})([0-9]{2}):?([0-9]{2})$/
        (match, year, month, date, hours, minutes, seconds, timezoneSign, timezoneHours, timezoneMinutes) =>

          @_year = Number(year)
          @_month = Number(month)
          @_date = Number(date)
          @_hours = Number(hours)
          @_minutes = Number(minutes)
          @_seconds = Number(seconds)

          @_timezone = Number(timezoneMinutes) + 60 * Number(timezoneHours)
          @_timezone *= -1 if timezoneSign is '-'

          @_utcTime = new Date(timeString)
          @_localTime = new Date(@_utcTime.getTime() + @_timezone * 60000)
      )

    # -------------------------------------------

    format: (str) ->
      str.replace /(HH?|hh?|mm?|ss?|do|d{1,4}|Do|DD?|MM?M?M?|YYY?Y?|a|A)/g, (match, token) =>
        return @_tokens[token].apply(@) if @_tokens[token]?
        token

    # -------------------------------------------

    diff: ->
      Math.floor(((new Date).getTime() - @_utcTime.getTime()) / 1000)

    # -------------------------------------------

    inFuture: ->
      @diff() < 0

    # -------------------------------------------

    inPast: ->
      @diff() > 0

    # -------------------------------------------

    fromNow: (absolute) ->
      past = true

      difference = @diff()

      if difference < 0
        difference *= -1
        past = false

      relative = 'now'

      if difference > @_periods.year * 1.5
        relative = @_relativeTime.yy.replace('%d', Math.round(difference / @_periods.year))
      else if difference >= @_periods.year
        relative = @_relativeTime.y
      else if difference > @_periods.month * 1.5
        relative = @_relativeTime.MM.replace('%d', Math.round(difference / @_periods.month))
      else if difference >= @_periods.month
        relative = @_relativeTime.M
      else if difference > @_periods.day * 1.5
        relative = @_relativeTime.dd.replace('%d', Math.round(difference / @_periods.day))
      else if difference >= @_periods.day
        relative = @_relativeTime.d
      else if difference > @_periods.hour * 1.5
        relative = @_relativeTime.hh.replace('%d', Math.round(difference / @_periods.hour))
      else if difference >= @_periods.hour
        relative = @_relativeTime.h
      else if difference > @_periods.minute * 1.5
        relative = @_relativeTime.mm.replace('%d', Math.round(difference / @_periods.minute))
      else if difference >= @_periods.minute
        relative = @_relativeTime.m
      else
        relative = @_relativeTime.s

      if not absolute
        if past
          relative = @_relativeTime.past.replace('%s', relative)
        else
          relative = @_relativeTime.future.replace('%s', relative)

      relative

    # -------------------------------------------

    _makeTwoDigits: (n) ->
      return "0#{n}" if n < 10
      return "#{n}"

    # -------------------------------------------

    _numerate: (n) ->
      if n >= 20 or n < 10
        return "#{n}st" if n % 10 is 1
        return "#{n}nd" if n % 10 is 2
        return "#{n}rd" if n % 10 is 3
      return "#{n}th"

    # -------------------------------------------

    utc: ->
      @_useUTC = true
      @

    # -------------------------------------------

    local: ->
      @_useUTC = false
      @

    # -------------------------------------------

    date: ->
      return @_utcTime.getUTCDate() if @_useUTC
      return @_date

    # -------------------------------------------

    month: ->
      return @_utcTime.getUTCMonth()+1 if @_useUTC
      return @_month

    # -------------------------------------------

    year: ->
      return @_utcTime.getUTCFullYear() if @_useUTC
      return @_year

    # -------------------------------------------

    hours: ->
      return @_utcTime.getUTCHours() if @_useUTC
      return @_hours

    # -------------------------------------------

    minutes: ->
      return @_utcTime.getUTCMinutes() if @_useUTC
      return @_minutes

    # -------------------------------------------

    seconds: ->
      return @_utcTime.getUTCSeconds() if @_useUTC
      return @_seconds

    # -------------------------------------------

    day: ->
      return @_utcTime.getUTCDay() if @_useUTC
      return @_localTime.getUTCDay()
