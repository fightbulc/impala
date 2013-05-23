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

    # -------------------------------------------

    _ddd: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

    # -------------------------------------------

    constructor: (timeString = "2013-05-25T06:00:00+0200") ->
      timeString.replace(
        /^([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})([\+\-]{1})([0-9]{2}):?([0-9]{2})$/
        (match, year, month, date, hours, minutes, seconds, timezoneSign, timezoneHours, timezoneMinutes) =>

          @year = Number(year)
          @month = Number(month)
          @date = Number(date)
          @hours = Number(hours)
          @minutes = Number(minutes)
          @seconds = Number(seconds)

          @timezone = Number(timezoneMinutes) + 60 * Number(timezoneHours)
          @timezone *= -1 if timezoneSign is '-'

          @utcTime = new Date(timeString)
          @localTime = new Date(@utcTime.getTime() + @timezone * 60000)
      )

    # -------------------------------------------

    format: (str) ->
      str.replace(/(d|ddd|dddd)/g, '')

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
      return @utcTime.getUTCDate() if @_useUTC
      return @date

    # -------------------------------------------

    month: ->
      return @utcTime.getUTCMonth()+1 if @_useUTC
      return @month

    # -------------------------------------------

    year: ->
      return @utcTime.getUTCFullYear() if @_useUTC
      return @year

    # -------------------------------------------

    hours: ->
      return @utcTime.getUTCHours() if @_useUTC
      return @hours

    # -------------------------------------------

    hh: ->
      h = @hours()
      return "0#{h}" if h < 10
      return "#{h}"

    # -------------------------------------------

    minutes: ->
      return @utcTime.getUTCMinutes() if @_useUTC
      return @minutes

    # -------------------------------------------

    mm: ->
      m = @minutes()
      return "0#{m}" if m < 10
      return "#{m}"

    # -------------------------------------------

    seconds: ->
      return @utcTime.getUTCSeconds() if @_useUTC
      return @seconds

    # -------------------------------------------

    ss: ->
      s = @seconds()
      return "0#{s}" if s < 10
      return "#{s}"

    # -------------------------------------------

    day: ->
      return @utcTime.getUTCDay() if @_useUTC
      return @localTime.getUTCDate()

    # -------------------------------------------

    ddd: ->
      @_ddd[@day()]

    # -------------------------------------------

    dddd: ->
      @_dddd[@day()]