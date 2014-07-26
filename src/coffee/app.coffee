class ViewModel
    constructor: (@io, @config) ->
        @running = ko.observable(false)
        @pattern = ko.observable("")
        @events = ko.observableArray([])
        @unexpectedError = ko.observable(false)
        @alreadySniffing = ko.observable(false)

        @showTable = ko.computed =>
            @events().length > 0

        @canStart = ko.computed =>
            not @running() and @pattern().length > 0


    start: () ->
        this.clearAlert()
        @events([])
        $.ajax '/pattern',
            type: 'POST'
            data:
                pattern: @pattern()
                rocketio_session: @io.session
            success: () =>
                @io.on 'event', (events) =>
                    this.rotate(_.map(events, (e) => this.format(e)))
                @running(true)
            error: (jqXHR, textStatus, errorThrown) =>
                if jqXHR.status == 503
                    @alreadySniffing(true)
                else
                    @unexpectedError(true)


    stop: () ->
        this.clearAlert()
        $.ajax '/pattern',
            type: 'DELETE'
            success: () =>
                @io.removeListener('event')
                @running(false)
            error: (jqXHR, textStatus, errorThrown) =>
                @unexpectedError(true)

    selectPattern: (data, event) ->
        this.clearAlert()
        @pattern(event.toElement.innerText)
        if @running()
            this.stopThenStart()
        else
            this.start()

    submit: () ->
        this.clearAlert()
        if @pattern().length > 0
            if @running()
                this.stopThenStart()
            else
                this.start()

    # Private Functions

    stopThenStart: () ->
        $.ajax '/pattern',
            type: 'DELETE'
            success: () =>
                @io.removeListener('event')
                @running(false)
                this.start()
            error: (jqXHR, textStatus, errorThrown) =>
                @unexpectedError(true)

    clearAlert: () =>
        @unexpectedError(false)
        @alreadySniffing(false)

    format: (event) ->
        tag: event.tag
        time: (new Date(event.time * 1000)).toLocaleString()
        record: JSON.stringify(event.record)

    rotate: (events) ->
        current = @events()
        tmp = current.concat(events)
        if tmp.length > @config.max_events
            @events(tmp.slice(tmp.length - @config.max_events, tmp.length))
        else
            @events(tmp)

$ ->
    config_elem = $('#config')
    config =
        max_events: config_elem.data('max-events')

    io = new RocketIO().connect();
    ko.applyBindings(new ViewModel(io, config))
